cmake_minimum_required(VERSION 3.24)

project(example LANGUAGES CXX)

include(CTest)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(USE_CCACHE "Use ccache when it is available" ON)
if(USE_CCACHE AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    message(STATUS "C++ compiler cache: ${CCACHE_PROGRAM}")
  endif()
endif()

set(_servicelib_source_dir_default "")
if(DEFINED ENV{SERVICELIB_SOURCE_DIR})
  set(_servicelib_source_dir_default "$ENV{SERVICELIB_SOURCE_DIR}")
endif()
set(SERVICELIB_SOURCE_DIR "${_servicelib_source_dir_default}" CACHE PATH
    "Path to a cppboostservicelib source checkout")
unset(_servicelib_source_dir_default)
option(FETCH_CPP_DEPENDENCIES
       "Fetch the pinned cppboostservicelib source tree when absent" OFF)
set(CPPBOOSTSERVICELIB_REPOSITORY
    "https://github.com/gorundebug/cppboostservicelib.git" CACHE STRING
    "Standalone cppboostservicelib repository")
set(CPPBOOSTSERVICELIB_REVISION
    "v0.2.42" CACHE STRING
    "Pinned cppboostservicelib revision")
set(CPPBOOSTSERVICELIB_DEPENDENCY_MODE "CONAN" CACHE STRING
    "Dependency provider used for a source-tree cppboostservicelib build")
set(CPPBOOSTSERVICELIB_BUILD_TESTS OFF CACHE BOOL
    "Do not build framework self-tests in a generated consumer workspace" FORCE)

set(CPPBOOSTSERVICELIB_ENABLE_GRPC ON
    CACHE BOOL "Build asio-grpc support" FORCE)
set(CPPBOOSTSERVICELIB_ENABLE_CRON ON
    CACHE BOOL "Build the libcron data source" FORCE)
set(CPPBOOSTSERVICELIB_ENABLE_KAFKA ON
    CACHE BOOL "Build librdkafka support" FORCE)
set(CPPBOOSTSERVICELIB_ENABLE_OTEL ON
    CACHE BOOL "Build OpenTelemetry tracing and logging support" FORCE)

if(SERVICELIB_SOURCE_DIR)
  add_subdirectory(
      "${SERVICELIB_SOURCE_DIR}"
      "${CMAKE_BINARY_DIR}/_deps/cppboostservicelib-build"
      EXCLUDE_FROM_ALL)
elseif(FETCH_CPP_DEPENDENCIES)
  include(FetchContent)
  FetchContent_Declare(servicegen_cppboostservicelib
      GIT_REPOSITORY "${CPPBOOSTSERVICELIB_REPOSITORY}"
      GIT_TAG "${CPPBOOSTSERVICELIB_REVISION}"
      GIT_SHALLOW FALSE
      GIT_PROGRESS TRUE)
  FetchContent_MakeAvailable(servicegen_cppboostservicelib)
else()
  find_package(cppboostservicelib CONFIG REQUIRED)
endif()

if(NOT TARGET servicelib::servicelib)
  message(FATAL_ERROR
      "cppboostservicelib did not provide servicelib::servicelib")
endif()
if(NOT TARGET servicelib::otel)
  message(FATAL_ERROR
      "cppboostservicelib was built without OpenTelemetry support")
endif()
if(NOT TARGET servicelib::grpc)
  message(FATAL_ERROR
      "cppboostservicelib was built without asio-grpc support")
endif()

if(NOT TARGET servicelib::cron)
  message(FATAL_ERROR
      "cppboostservicelib was built without libcron support")
endif()

if(NOT TARGET servicelib::kafka)
  message(FATAL_ERROR
      "cppboostservicelib was built without librdkafka support")
endif()

add_subdirectory(inventory_service_api)
add_subdirectory(model_cpp)
add_subdirectory(order_service_api)
add_subdirectory(analyticsservice)
add_subdirectory(inventoryservice)
add_subdirectory(orderservice)