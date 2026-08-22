#!/usr/bin/env bash
set -euo pipefail

# Configure and build first so this command also works with an empty build
# volume on a clean CI runner.
preset="${1:-docker-debug}"
case "$preset" in
  docker-debug|docker-release) ;;
  *)
    echo "unsupported C++ Docker preset: $preset" >&2
    exit 2
    ;;
esac

exec docker compose -f docker-compose.cmake.generated.yml run --build --rm \
  -e SERVICEGEN_CPP_CMAKE_PRESET="$preset" \
  -e CPPBOOSTSERVICELIB_PROFILING="${CPPBOOSTSERVICELIB_PROFILING:-OFF}" \
  -e CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS:-OFF}" \
  cpp-build \
  /bin/bash -lc \
  'source scripts/configure-git-auth.generated.sh &&
   ./scripts/run_with_progress.generated.sh "Configure $SERVICEGEN_CPP_CMAKE_PRESET" cmake --preset "$SERVICEGEN_CPP_CMAKE_PRESET" \
     -DSERVICEGEN_FETCH_CPP_DEPENDENCIES="${SERVICEGEN_FETCH_CPP_DEPENDENCIES:-OFF}" \
     -DCPPBOOSTSERVICELIB_PROFILING="$CPPBOOSTSERVICELIB_PROFILING" \
     -DCPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="$CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS" &&
   ./scripts/run_with_progress.generated.sh "Build $SERVICEGEN_CPP_CMAKE_PRESET" cmake --build --preset "$SERVICEGEN_CPP_CMAKE_PRESET" --parallel &&
   ./scripts/run_with_progress.generated.sh "Test $SERVICEGEN_CPP_CMAKE_PRESET" ctest --preset "$SERVICEGEN_CPP_CMAKE_PRESET"'