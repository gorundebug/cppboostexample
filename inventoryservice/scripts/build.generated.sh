#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dependency-proxy-env.generated.sh"

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

exec docker compose -f docker-compose.cmake.generated.yml run --build --rm \
  -e CPP_CMAKE_PRESET="$preset" \
  -e CPPBOOSTSERVICELIB_PROFILING="${CPPBOOSTSERVICELIB_PROFILING:-OFF}" \
  -e CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS:-OFF}" \
  cpp-build \
  /bin/bash -lc \
  'source scripts/configure-git-auth.generated.sh &&
   build_type=Debug &&
   if [[ "$CPP_CMAKE_PRESET" = docker-release ]]; then build_type=Release; fi &&
   ./scripts/conan-install.generated.sh "$build_type" "/workspace/build/conan-${build_type,,}" &&
   conan_toolchain="$(cat "/workspace/build/conan-${build_type,,}/toolchain.path")" &&
   ./scripts/run_with_progress.generated.sh "Configure $CPP_CMAKE_PRESET" cmake --preset "$CPP_CMAKE_PRESET" \
     --fresh \
     -DCMAKE_TOOLCHAIN_FILE="$conan_toolchain" \
     -DFETCH_CPP_DEPENDENCIES="${FETCH_CPP_DEPENDENCIES:-OFF}" \
     -DCPPBOOSTSERVICELIB_PROFILING="$CPPBOOSTSERVICELIB_PROFILING" \
     -DCPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="$CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS" &&
   ./scripts/run_with_progress.generated.sh "Build $CPP_CMAKE_PRESET" cmake --build --preset "$CPP_CMAKE_PRESET" --parallel'