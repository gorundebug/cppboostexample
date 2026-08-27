#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dependency-proxy-env.generated.sh"

sanitizer="${1:?expected asan or tsan}"
case "$sanitizer" in
  asan)
    conan_sanitizer=Address
    cmake_options=(
      -DCPPBOOSTSERVICELIB_ASAN=ON
      -DCPPBOOSTSERVICELIB_UBSAN=ON
    )
    ;;
  tsan)
    conan_sanitizer=Thread
    cmake_options=(-DCPPBOOSTSERVICELIB_TSAN=ON)
    ;;
  *)
    echo "unsupported sanitizer: $sanitizer" >&2
    exit 2
    ;;
esac

options="${cmake_options[*]}"
exec docker compose -f docker-compose.cmake.generated.yml run --build --rm \
  -e CPP_SANITIZER="$sanitizer" \
  -e CPP_CONAN_SANITIZER="$conan_sanitizer" \
  -e SANITIZER_INTEGRATION="${SANITIZER_INTEGRATION:-1}" \
  -e CPP_SANITIZER_OPTIONS="$options" cpp-build \
  /bin/bash -lc \
  'set -euo pipefail
   source scripts/configure-git-auth.generated.sh
   build_dir="/workspace/build/sanitizers/$CPP_SANITIZER"
   conan_dir="/workspace/build/conan-debug-$CPP_SANITIZER"
   case "$CPP_SANITIZER" in
     asan)
       sanitizer_flags='"'"'["-fsanitize=address","-fno-omit-frame-pointer"]'"'"'
       ;;
     tsan)
       sanitizer_flags='"'"'["-fsanitize=thread","-fno-omit-frame-pointer"]'"'"'
       ;;
   esac
   conan_sanitizer_args=(
     -s:h "compiler.sanitizer=$CPP_CONAN_SANITIZER"
     -c:h "tools.build:cflags=$sanitizer_flags"
     -c:h "tools.build:cxxflags=$sanitizer_flags"
     -c:h "tools.build:sharedlinkflags=$sanitizer_flags"
     -c:h "tools.build:exelinkflags=$sanitizer_flags"
   )
   ./scripts/conan-install.generated.sh Debug "$conan_dir" \
     "${conan_sanitizer_args[@]}"
   conan_toolchain="$(cat "$conan_dir/toolchain.path")"
   cmake -S . -B "$build_dir" -G Ninja \
     --fresh \
     -DCMAKE_BUILD_TYPE=Debug \
     -DCMAKE_TOOLCHAIN_FILE="$conan_toolchain" \
     -DCPPBOOSTSERVICELIB_SOURCE_DIR="$CPPBOOSTSERVICELIB_SOURCE_DIR" \
     -DFETCH_CPP_DEPENDENCIES=OFF \
     $CPP_SANITIZER_OPTIONS
   cmake --build "$build_dir" --parallel
   case "$CPP_SANITIZER" in
     asan)
       ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 \
       UBSAN_OPTIONS=halt_on_error=1 \
         ctest --test-dir "$build_dir" --output-on-failure
       ;;
     tsan)
       TSAN_OPTIONS=halt_on_error=1 \
         ctest --test-dir "$build_dir" --output-on-failure
       ;;
   esac
   if [[ "$SANITIZER_INTEGRATION" == "1" ]]; then
     scripts/sanitizer-integration.generated.sh \
       "$build_dir" "$CPP_SANITIZER"
   fi'
