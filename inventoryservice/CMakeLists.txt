cmake_minimum_required(VERSION 3.24)

# This file is both a standalone service project and a workspace subdirectory.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(example_inventory_service LANGUAGES CXX)
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
  set(_servicegen_modules_root_default "${CMAKE_CURRENT_SOURCE_DIR}/modules")
  set(MODULES_ROOT "${_servicegen_modules_root_default}" CACHE PATH
      "Path containing local generated contract modules")
  option(FETCH_CPP_DEPENDENCIES
         "Fetch pinned cppboostservicelib and missing contract modules" ON)
  set(CPPBOOSTSERVICELIB_REPOSITORY "https://github.com/gorundebug/cppboostservicelib.git" CACHE STRING
      "Standalone cppboostservicelib repository")
  set(CPPBOOSTSERVICELIB_REVISION "v0.2.74" CACHE STRING
      "Pinned cppboostservicelib revision")
  set(CPPBOOSTSERVICELIB_ENABLE_GRPC ON
      CACHE BOOL "Build asio-grpc support" FORCE)
  set(CPPBOOSTSERVICELIB_ENABLE_KAFKA OFF
      CACHE BOOL "Build librdkafka support" FORCE)
  set(CPPBOOSTSERVICELIB_ENABLE_OTEL ON
      CACHE BOOL "Build OpenTelemetry tracing and logging support" FORCE)
  set(CPPBOOSTSERVICELIB_BUILD_TESTS OFF CACHE BOOL
      "Do not register framework self-tests in a standalone consumer" FORCE)
  # The canonical standalone toolchain installs the exact dependency graph
  # through Conan whether the framework source is local or fetched. Keep this
  # as an overridable cache default so an explicit host build may still select
  # another provider without silently mixing Conan and system packages.
  set(CPPBOOSTSERVICELIB_DEPENDENCY_MODE "CONAN" CACHE STRING
      "Dependency provider for standalone cppboostservicelib")

  if(SERVICELIB_SOURCE_DIR)
    add_subdirectory(
        "${SERVICELIB_SOURCE_DIR}"
        "${CMAKE_BINARY_DIR}/_deps/cppboostservicelib-build"
        EXCLUDE_FROM_ALL)
  elseif(FETCH_CPP_DEPENDENCIES)
    include(FetchContent)
    if(DEFINED ENV{DEPENDENCY_GITHUB_RAW_URL} AND
       NOT "$ENV{DEPENDENCY_GITHUB_RAW_URL}" STREQUAL "" AND
       CPPBOOSTSERVICELIB_REPOSITORY MATCHES "^https://github.com/")
      string(REGEX REPLACE "^https://github.com/" ""
          _servicegen_framework_path "${CPPBOOSTSERVICELIB_REPOSITORY}")
      string(REGEX REPLACE "\\.git$" ""
          _servicegen_framework_path "${_servicegen_framework_path}")
      FetchContent_Declare(servicegen_cppboostservicelib
          URL "$ENV{DEPENDENCY_GITHUB_RAW_URL}/${_servicegen_framework_path}/archive/${CPPBOOSTSERVICELIB_REVISION}.tar.gz"
          DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
    else()
      FetchContent_Declare(servicegen_cppboostservicelib
          GIT_REPOSITORY "${CPPBOOSTSERVICELIB_REPOSITORY}"
          GIT_TAG "${CPPBOOSTSERVICELIB_REVISION}"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
    endif()
    FetchContent_MakeAvailable(servicegen_cppboostservicelib)
  else()
    find_package(cppboostservicelib CONFIG REQUIRED)
  endif()

  if(NOT TARGET example_inventory_service_api)
    set(_servicegen_module_source "${MODULES_ROOT}/inventory_service_api")
    if(EXISTS "${_servicegen_module_source}/CMakeLists.txt")
      add_subdirectory("${_servicegen_module_source}"
          "${CMAKE_BINARY_DIR}/_modules/inventory_service_api")
    elseif(FETCH_CPP_DEPENDENCIES)
      include(FetchContent)
      FetchContent_Declare(servicegen_module_inventory_service_api
          GIT_REPOSITORY "https://github.com/gorundebug/cppboostexample.git"
          GIT_TAG "v0.2.74"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
      FetchContent_MakeAvailable(servicegen_module_inventory_service_api)
    else()
      message(FATAL_ERROR "Contract module inventory_service_api was not found")
    endif()
  endif()
  if(NOT TARGET example_model)
    set(_servicegen_module_source "${MODULES_ROOT}/model_cpp")
    if(EXISTS "${_servicegen_module_source}/CMakeLists.txt")
      add_subdirectory("${_servicegen_module_source}"
          "${CMAKE_BINARY_DIR}/_modules/model_cpp")
    elseif(FETCH_CPP_DEPENDENCIES)
      include(FetchContent)
      FetchContent_Declare(servicegen_module_model
          GIT_REPOSITORY "https://github.com/gorundebug/cppboostexample.git"
          GIT_TAG "v0.2.74"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
      FetchContent_MakeAvailable(servicegen_module_model)
    else()
      message(FATAL_ERROR "Contract module model_cpp was not found")
    endif()
  endif()
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(JEMALLOC REQUIRED IMPORTED_TARGET jemalloc)

set(_servicegen_include_root
    "${CMAKE_CURRENT_BINARY_DIR}/servicegen-include")
file(MAKE_DIRECTORY "${_servicegen_include_root}")
if(NOT EXISTS
    "${_servicegen_include_root}/inventoryservice")
  file(CREATE_LINK "${CMAKE_CURRENT_SOURCE_DIR}"
      "${_servicegen_include_root}/inventoryservice"
      SYMBOLIC COPY_ON_ERROR)
endif()

add_executable(example_inventory_service
    cmd/service/main.cpp
    internal/app/service.generated.cpp
    internal/app/grpc_service.generated.cpp

    internal/app/service.cpp
    internal/functions/inventory_item/get_inventory_item_data.cpp
)
target_compile_features(example_inventory_service PRIVATE cxx_std_20)
target_include_directories(example_inventory_service PRIVATE "${_servicegen_include_root}")
target_link_libraries(example_inventory_service PRIVATE
    PkgConfig::JEMALLOC
    servicelib::servicelib servicelib::otel servicelib::grpc
    example_inventory_service_api
    example_model
    example_inventory_service_api
)

if(BUILD_TESTING)
add_executable(example_inventory_service_typed_config config/config.generated.cpp)
target_compile_features(example_inventory_service_typed_config PRIVATE cxx_std_20)
target_include_directories(example_inventory_service_typed_config PRIVATE
    "${_servicegen_include_root}")
target_link_libraries(example_inventory_service_typed_config PRIVATE
    servicelib::servicelib)
add_test(NAME example_inventory_service_typed_config COMMAND example_inventory_service_typed_config)

if(NOT TARGET GTest::gtest_main)
  if(CPPBOOSTSERVICELIB_DEPENDENCY_MODE STREQUAL "CONAN")
    find_package(GTest CONFIG REQUIRED)
  else()
    include(FetchContent)
    FetchContent_Declare(servicegen_googletest
        URL "${CPPBOOSTSERVICELIB_GITHUB_ARCHIVE_BASE}/google/googletest/archive/refs/tags/${CPPBOOSTSERVICELIB_GOOGLETEST_VERSION}.tar.gz"
        DOWNLOAD_EXTRACT_TIMESTAMP FALSE)
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(servicegen_googletest)
  endif()
endif()
include(GoogleTest)

add_executable(example_inventory_service_unit_tests
    internal/functions/endpoint/process_order_item_source_test.cpp
    internal/functions/inventory_item/get_inventory_item_data_test.cpp
)
target_compile_features(example_inventory_service_unit_tests PRIVATE cxx_std_20)
target_include_directories(example_inventory_service_unit_tests PRIVATE
    "${_servicegen_include_root}")
target_link_libraries(example_inventory_service_unit_tests PRIVATE
    servicelib::servicelib GTest::gtest_main servicelib::grpc
    example_inventory_service_api
    example_model
    example_inventory_service_api
)
gtest_discover_tests(example_inventory_service_unit_tests)

endif()