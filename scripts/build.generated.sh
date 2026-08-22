#!/usr/bin/env bash
set -euo pipefail

# Docker is the canonical C++ build environment. The compose file deliberately
# leaves the platform unset so Docker selects the runner's native architecture.
preset="${1:-docker-debug}"
case "$preset" in
  docker-debug|docker-release) ;;
  *)
    echo "unsupported C++ Docker preset: $preset" >&2
    exit 2
    ;;
esac

set --
if [[ -n "${SERVICEGEN_CPPBOOST_SOURCE_CACHE_DIR:-}" ]]; then
  if [[ ! -d "$SERVICEGEN_CPPBOOST_SOURCE_CACHE_DIR" ]]; then
    echo "C++ dependency source cache does not exist: $SERVICEGEN_CPPBOOST_SOURCE_CACHE_DIR" >&2
    exit 2
  fi
  source_cache_key="$(basename "$(dirname "${SERVICEGEN_CPPBOOST_SOURCE_CACHE_DIR%/}")")"
  export SERVICEGEN_CPPBOOST_BUILD_VOLUME="${SERVICEGEN_CPPBOOST_BUILD_VOLUME:-cppboostexample_cpp-cmake-build-${source_cache_key}}"
  set -- "$@" \
    --volume "$SERVICEGEN_CPPBOOST_SOURCE_CACHE_DIR:/servicegen-cpp-source-cache:ro" \
    -e SERVICEGEN_CPPBOOST_SOURCE_CACHE=1
fi

exec docker compose -f docker-compose.cmake.generated.yml run --build --rm \
  -e SERVICEGEN_CPP_CMAKE_PRESET="$preset" \
  -e CPPBOOSTSERVICELIB_PROFILING="${CPPBOOSTSERVICELIB_PROFILING:-OFF}" \
  -e CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS:-OFF}" \
  "$@" \
  cpp-build \
  /bin/bash -lc \
  'source scripts/configure-git-auth.generated.sh &&
   source_cache_args=(
     -U "FETCHCONTENT_SOURCE_DIR_*"
     -DFETCHCONTENT_UPDATES_DISCONNECTED=ON
     -U OTELCPP_PROTO_PATH
   ) &&
   if [[ "${SERVICEGEN_CPPBOOST_SOURCE_CACHE:-0}" = "1" ]]; then
     source_cache_args=(
       -DFETCHCONTENT_UPDATES_DISCONNECTED=ON
       -DFETCHCONTENT_SOURCE_DIR_BOOST=/servicegen-cpp-source-cache/boost-src
       -DFETCHCONTENT_SOURCE_DIR_YAML-CPP=/servicegen-cpp-source-cache/yaml-cpp-src
       -DFETCHCONTENT_SOURCE_DIR_GOOGLETEST=/servicegen-cpp-source-cache/googletest-src
       -DFETCHCONTENT_SOURCE_DIR_SERVICEGEN_GOOGLETEST=/servicegen-cpp-source-cache/googletest-src
       -DFETCHCONTENT_SOURCE_DIR_GRPC=/servicegen-cpp-source-cache/grpc-src
       -DFETCHCONTENT_SOURCE_DIR_ASIO-GRPC=/servicegen-cpp-source-cache/asio-grpc-src
       -DFETCHCONTENT_SOURCE_DIR_LIBRDKAFKA=/servicegen-cpp-source-cache/librdkafka-src
       -DFETCHCONTENT_SOURCE_DIR_OPENTELEMETRY-CPP=/servicegen-cpp-source-cache/opentelemetry-cpp-src
       -DOTELCPP_PROTO_PATH=/servicegen-cpp-source-cache/opentelemetry-cpp-build/opentelemetry-proto-prefix/src/opentelemetry-proto
     )
   fi &&
   ./scripts/run_with_progress.generated.sh "Configure $SERVICEGEN_CPP_CMAKE_PRESET" cmake --preset "$SERVICEGEN_CPP_CMAKE_PRESET" \
     -DSERVICEGEN_FETCH_CPP_DEPENDENCIES="${SERVICEGEN_FETCH_CPP_DEPENDENCIES:-OFF}" \
     -DCPPBOOSTSERVICELIB_PROFILING="$CPPBOOSTSERVICELIB_PROFILING" \
     -DCPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="$CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS" \
     "${source_cache_args[@]}" &&
   ./scripts/run_with_progress.generated.sh "Build $SERVICEGEN_CPP_CMAKE_PRESET" cmake --build --preset "$SERVICEGEN_CPP_CMAKE_PRESET" --parallel'