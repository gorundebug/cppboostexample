#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dependency-proxy-env.generated.sh"

sanitizer="${1:?expected asan or tsan}"
case "$sanitizer" in
  asan)
    cmake_options=(
      -DCPPBOOSTSERVICELIB_ASAN=ON
      -DCPPBOOSTSERVICELIB_UBSAN=ON
    )
    ;;
  tsan)
    cmake_options=(-DCPPBOOSTSERVICELIB_TSAN=ON)
    ;;
  *)
    echo "unsupported sanitizer: $sanitizer" >&2
    exit 2
    ;;
esac

options="${cmake_options[*]}"
exec docker compose -f docker-compose.cmake.generated.yml run --build --rm \
  -e SERVICEGEN_CPP_SANITIZER="$sanitizer" \
  -e SERVICEGEN_SANITIZER_INTEGRATION="${SERVICEGEN_SANITIZER_INTEGRATION:-1}" \
  -e SERVICEGEN_CPP_SANITIZER_OPTIONS="$options" cpp-build \
  /bin/bash -lc \
  'set -euo pipefail
   source scripts/configure-git-auth.generated.sh
   build_dir="build/sanitizers/$SERVICEGEN_CPP_SANITIZER"
   conan_dir="build/conan-sanitizers/$SERVICEGEN_CPP_SANITIZER"
   case "$SERVICEGEN_CPP_SANITIZER" in
     asan)
       conan_sanitizer="Address"
       conan_compile_flags="[\"-fsanitize=address\",\"-fno-omit-frame-pointer\"]"
       conan_link_flags="[\"-fsanitize=address\"]"
       ;;
     tsan)
       conan_sanitizer="Thread"
       conan_compile_flags="[\"-fsanitize=thread\",\"-fno-omit-frame-pointer\"]"
       conan_link_flags="[\"-fsanitize=thread\"]"
       ;;
   esac
   ./scripts/conan-install.generated.sh RelWithDebInfo "$conan_dir" \
     -s:h "compiler.sanitizer=$conan_sanitizer" \
     -c:h "tools.build:cflags=$conan_compile_flags" \
     -c:h "tools.build:cxxflags=$conan_compile_flags" \
     -c:h "tools.build:sharedlinkflags=$conan_link_flags" \
     -c:h "tools.build:exelinkflags=$conan_link_flags"
   conan_toolchain="$(cat "$conan_dir/toolchain.path")"
   cmake -S . -B "$build_dir" -G Ninja \
     --fresh \
     -DCMAKE_BUILD_TYPE=RelWithDebInfo \
     -DCMAKE_TOOLCHAIN_FILE="$conan_toolchain" \
     -DCPPBOOSTSERVICELIB_SOURCE_DIR="$CPPBOOSTSERVICELIB_SOURCE_DIR" \
     -DSERVICEGEN_FETCH_CPP_DEPENDENCIES=OFF \
     $SERVICEGEN_CPP_SANITIZER_OPTIONS
   cmake --build "$build_dir" --parallel
   case "$SERVICEGEN_CPP_SANITIZER" in
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
   if [[ "$SERVICEGEN_SANITIZER_INTEGRATION" == "1" ]]; then
     scripts/sanitizer-integration.generated.sh \
       "$build_dir" "$SERVICEGEN_CPP_SANITIZER"
   fi'