cmake_minimum_required(VERSION 3.24)

# This file is both a standalone service project and a workspace subdirectory.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(example_order_service LANGUAGES CXX)
  include(CTest)
  set(CMAKE_CXX_STANDARD 20)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)

  option(SERVICEGEN_USE_CCACHE "Use ccache when it is available" ON)
  if(SERVICEGEN_USE_CCACHE AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
    find_program(SERVICEGEN_CCACHE_PROGRAM ccache)
    if(SERVICEGEN_CCACHE_PROGRAM)
      set(CMAKE_CXX_COMPILER_LAUNCHER "${SERVICEGEN_CCACHE_PROGRAM}")
      message(STATUS "C++ compiler cache: ${SERVICEGEN_CCACHE_PROGRAM}")
    endif()
  endif()

  set(CPPBOOSTSERVICELIB_SOURCE_DIR "" CACHE PATH
      "Path to a cppboostservicelib source checkout")
  set(_servicegen_modules_root_default "${CMAKE_CURRENT_SOURCE_DIR}/..")
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/modules")
    set(_servicegen_modules_root_default "${CMAKE_CURRENT_SOURCE_DIR}/modules")
  endif()
  set(SERVICEGEN_MODULES_ROOT "${_servicegen_modules_root_default}" CACHE PATH
      "Path containing local generated contract modules")
  option(SERVICEGEN_FETCH_CPP_DEPENDENCIES
         "Fetch pinned cppboostservicelib and missing contract modules" ON)
  set(CPPBOOSTSERVICELIB_REPOSITORY "https://github.com/gorundebug/cppboostservicelib.git" CACHE STRING
      "Standalone cppboostservicelib repository")
  set(CPPBOOSTSERVICELIB_REVISION "v0.2.12" CACHE STRING
      "Pinned cppboostservicelib revision")
  set(CPPBOOSTSERVICELIB_ENABLE_GRPC ON
      CACHE BOOL "Build asio-grpc support" FORCE)
  set(CPPBOOSTSERVICELIB_ENABLE_KAFKA ON
      CACHE BOOL "Build librdkafka support" FORCE)
  set(CPPBOOSTSERVICELIB_ENABLE_OTEL ON
      CACHE BOOL "Build OpenTelemetry tracing and logging support" FORCE)
  set(CPPBOOSTSERVICELIB_BUILD_TESTS OFF CACHE BOOL
      "Do not register framework self-tests in a standalone consumer" FORCE)

  # A standalone generated service uses the same Conan dependency graph as the
  # complete workspace. The framework source may be local or fetched, while
  # its third-party packages always come from the selected Conan lockfile.
  if(SERVICEGEN_FETCH_CPP_DEPENDENCIES)
    set(CPPBOOSTSERVICELIB_DEPENDENCY_MODE "CONAN" CACHE STRING
        "Dependency provider for standalone cppboostservicelib" FORCE)
  endif()

  if(CPPBOOSTSERVICELIB_SOURCE_DIR)
    add_subdirectory(
        "${CPPBOOSTSERVICELIB_SOURCE_DIR}"
        "${CMAKE_BINARY_DIR}/_deps/cppboostservicelib-build"
        EXCLUDE_FROM_ALL)
  elseif(SERVICEGEN_FETCH_CPP_DEPENDENCIES)
    include(FetchContent)
    if(DEFINED ENV{SERVICEGEN_GITHUB_RAW_URL} AND
       NOT "$ENV{SERVICEGEN_GITHUB_RAW_URL}" STREQUAL "" AND
       CPPBOOSTSERVICELIB_REPOSITORY MATCHES "^https://github.com/")
      string(REGEX REPLACE "^https://github.com/" ""
          _servicegen_framework_path "${CPPBOOSTSERVICELIB_REPOSITORY}")
      string(REGEX REPLACE "\\.git$" ""
          _servicegen_framework_path "${_servicegen_framework_path}")
      FetchContent_Declare(servicegen_cppboostservicelib
          URL "$ENV{SERVICEGEN_GITHUB_RAW_URL}/${_servicegen_framework_path}/archive/${CPPBOOSTSERVICELIB_REVISION}.tar.gz"
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
    set(_servicegen_module_source "${SERVICEGEN_MODULES_ROOT}/inventory_service_api")
    if(EXISTS "${_servicegen_module_source}/CMakeLists.txt")
      add_subdirectory("${_servicegen_module_source}"
          "${CMAKE_BINARY_DIR}/_modules/inventory_service_api")
    elseif(SERVICEGEN_FETCH_CPP_DEPENDENCIES)
      include(FetchContent)
      FetchContent_Declare(servicegen_module_inventory_service_api
          GIT_REPOSITORY "https://github.com/gorundebug/cppboostexample-inventory-service-api.git"
          GIT_TAG "v0.2.12"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
      FetchContent_MakeAvailable(servicegen_module_inventory_service_api)
    else()
      message(FATAL_ERROR "Contract module inventory_service_api was not found")
    endif()
  endif()
  if(NOT TARGET example_model)
    set(_servicegen_module_source "${SERVICEGEN_MODULES_ROOT}/model")
    if(EXISTS "${_servicegen_module_source}/CMakeLists.txt")
      add_subdirectory("${_servicegen_module_source}"
          "${CMAKE_BINARY_DIR}/_modules/model")
    elseif(SERVICEGEN_FETCH_CPP_DEPENDENCIES)
      include(FetchContent)
      FetchContent_Declare(servicegen_module_model
          GIT_REPOSITORY "https://github.com/gorundebug/cppboostexample-model.git"
          GIT_TAG "v0.2.12"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
      FetchContent_MakeAvailable(servicegen_module_model)
    else()
      message(FATAL_ERROR "Contract module model was not found")
    endif()
  endif()
  if(NOT TARGET example_order_service_api)
    set(_servicegen_module_source "${SERVICEGEN_MODULES_ROOT}/order_service_api")
    if(EXISTS "${_servicegen_module_source}/CMakeLists.txt")
      add_subdirectory("${_servicegen_module_source}"
          "${CMAKE_BINARY_DIR}/_modules/order_service_api")
    elseif(SERVICEGEN_FETCH_CPP_DEPENDENCIES)
      include(FetchContent)
      FetchContent_Declare(servicegen_module_order_service_api
          GIT_REPOSITORY "https://github.com/gorundebug/cppboostexample-order-service-api.git"
          GIT_TAG "v0.2.12"
          GIT_SHALLOW FALSE
          GIT_PROGRESS TRUE)
      FetchContent_MakeAvailable(servicegen_module_order_service_api)
    else()
      message(FATAL_ERROR "Contract module order_service_api was not found")
    endif()
  endif()
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(JEMALLOC REQUIRED IMPORTED_TARGET jemalloc)

set(_servicegen_include_root
    "${CMAKE_CURRENT_BINARY_DIR}/servicegen-include")
file(MAKE_DIRECTORY "${_servicegen_include_root}")
if(NOT EXISTS
    "${_servicegen_include_root}/orderservice")
  file(CREATE_LINK "${CMAKE_CURRENT_SOURCE_DIR}"
      "${_servicegen_include_root}/orderservice"
      SYMBOLIC COPY_ON_ERROR)
endif()

add_executable(example_order_service
    cmd/service/main.cpp
    internal/app/service.generated.cpp

    internal/app/service.cpp
    internal/functions/map_order_item_result_to_order_state.cpp
    internal/functions/map_to_order_processed.cpp
    internal/functions/map_to_order_state.cpp
    internal/functions/process_order_items.cpp
    internal/functions/soft_deadline.cpp
)
target_compile_features(example_order_service PRIVATE cxx_std_20)
target_include_directories(example_order_service PRIVATE "${_servicegen_include_root}")
target_link_libraries(example_order_service PRIVATE
    PkgConfig::JEMALLOC
    servicelib::servicelib servicelib::otel servicelib::grpc servicelib::kafka
    example_inventory_service_api
    example_model
    example_order_service_api
    example_inventory_service_api
    example_order_service_api
)

add_executable(example_order_service_typed_config config/config.generated.cpp)
target_compile_features(example_order_service_typed_config PRIVATE cxx_std_20)
target_include_directories(example_order_service_typed_config PRIVATE
    "${_servicegen_include_root}")
target_link_libraries(example_order_service_typed_config PRIVATE
    servicelib::servicelib)
add_test(NAME example_order_service_typed_config COMMAND example_order_service_typed_config)

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

add_executable(example_order_service_unit_tests
    internal/functions/map_order_item_result_to_order_state_test.cpp
    internal/functions/map_to_order_processed_test.cpp
    internal/functions/map_to_order_state_test.cpp
    internal/functions/order_processed_endpoint_test.cpp
    internal/functions/process_order_item_test.cpp
    internal/functions/process_order_items_test.cpp
    internal/functions/process_order_test.cpp
    internal/functions/soft_deadline_test.cpp
)
target_compile_features(example_order_service_unit_tests PRIVATE cxx_std_20)
target_include_directories(example_order_service_unit_tests PRIVATE
    "${_servicegen_include_root}")
target_link_libraries(example_order_service_unit_tests PRIVATE
    servicelib::servicelib GTest::gtest_main servicelib::grpc servicelib::kafka
    example_inventory_service_api
    example_model
    example_order_service_api
    example_inventory_service_api
    example_order_service_api
)
gtest_discover_tests(example_order_service_unit_tests)