cmake_minimum_required(VERSION 3.24)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(example_inventory_service_api LANGUAGES CXX)
  include(CTest)
  set(CMAKE_CXX_STANDARD 20)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)

  set(_servicelib_source_dir_default "")
  if(DEFINED ENV{SERVICELIB_SOURCE_DIR})
    set(_servicelib_source_dir_default "$ENV{SERVICELIB_SOURCE_DIR}")
  endif()
  set(SERVICELIB_SOURCE_DIR "${_servicelib_source_dir_default}" CACHE PATH
      "Path to a cppboostservicelib source checkout")
  unset(_servicelib_source_dir_default)
  set(CPPBOOSTSERVICELIB_DEPENDENCY_MODE "CONAN" CACHE STRING "" FORCE)
  set(CPPBOOSTSERVICELIB_ENABLE_GRPC ON CACHE BOOL "" FORCE)
  set(CPPBOOSTSERVICELIB_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  if(SERVICELIB_SOURCE_DIR)
    add_subdirectory("${SERVICELIB_SOURCE_DIR}"
        "${CMAKE_BINARY_DIR}/_deps/cppboostservicelib-build" EXCLUDE_FROM_ALL)
  else()
    include(FetchContent)
    FetchContent_Declare(servicegen_servicelib
        GIT_REPOSITORY "https://github.com/gorundebug/cppboostservicelib.git"
        GIT_TAG "v0.2.42"
        GIT_SHALLOW TRUE)
    FetchContent_MakeAvailable(servicegen_servicelib)
  endif()
endif()

set(_GENERATED_DIR "${CMAKE_BINARY_DIR}/generated/example/inventory_service_api")
file(MAKE_DIRECTORY "${_GENERATED_DIR}")

asio_grpc_protobuf_generate(
    GENERATE_GRPC
    OUT_VAR _SERVICEGEN_PROTO_SOURCES
    OUT_DIR "${_GENERATED_DIR}"
    IMPORT_DIRS "${CMAKE_CURRENT_SOURCE_DIR}"
    PROTOS
      "${CMAKE_CURRENT_SOURCE_DIR}/proto/inventoryserviceapi/inventoryserviceapi.generated.proto"
      "${CMAKE_CURRENT_SOURCE_DIR}/proto/inventoryserviceapi/processorderitem/processorderitem.proto")

add_library(example_inventory_service_api ${_SERVICEGEN_PROTO_SOURCES})
target_compile_features(example_inventory_service_api PUBLIC cxx_std_20)
target_include_directories(example_inventory_service_api SYSTEM PUBLIC "${_GENERATED_DIR}")
target_link_libraries(example_inventory_service_api PUBLIC servicelib::grpc)

set(example_inventory_service_api_GENERATED_DIR "${_GENERATED_DIR}"
    CACHE INTERNAL "Generated protobuf/gRPC sources for inventory_service_api")