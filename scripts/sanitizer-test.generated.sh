#!/usr/bin/env bash
set -euo pipefail

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
  -e SERVICEGEN_CPP_SANITIZER_OPTIONS="$options" cpp-build \
  /bin/bash -lc \
  'set -euo pipefail
   source scripts/configure-git-auth.generated.sh
   build_dir="build/sanitizers/$SERVICEGEN_CPP_SANITIZER"
   host_tools_dir="build/sanitizers/host-tools"
   host_protoc="$host_tools_dir/third_party/protobuf/protoc"
   host_grpc_plugin="$host_tools_dir/grpc_cpp_plugin"
   cmake -S . -B "$build_dir" -G Ninja \
     -DCMAKE_BUILD_TYPE=Debug \
     -DFETCHCONTENT_QUIET=OFF \
     -DCPPBOOSTSERVICELIB_SOURCE_DIR="$CPPBOOSTSERVICELIB_SOURCE_DIR" \
     -DCPPBOOSTSERVICELIB_HOST_PROTOC_EXECUTABLE="$host_protoc" \
     -DCPPBOOSTSERVICELIB_HOST_GRPC_CPP_PLUGIN_EXECUTABLE="$host_grpc_plugin" \
     -DSERVICEGEN_FETCH_CPP_DEPENDENCIES="${SERVICEGEN_FETCH_CPP_DEPENDENCIES:-OFF}" \
     $SERVICEGEN_CPP_SANITIZER_OPTIONS
   if [[ ! -x "$host_protoc" || ! -x "$host_grpc_plugin" ]]; then
     cmake -S "$build_dir/_deps/grpc-src" -B "$host_tools_dir" -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DgRPC_BUILD_TESTS=OFF \
       -DgRPC_INSTALL=OFF \
       -Dprotobuf_BUILD_TESTS=OFF \
       -Dprotobuf_INSTALL=OFF \
       -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
       -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
       -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
       -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
       -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
       -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
     cmake --build "$host_tools_dir" \
       --target protoc grpc_cpp_plugin --parallel
   fi
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
   scripts/sanitizer-integration.generated.sh \
     "$build_dir" "$SERVICEGEN_CPP_SANITIZER"'