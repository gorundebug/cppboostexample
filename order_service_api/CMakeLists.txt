cmake_minimum_required(VERSION 3.24)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(example_order_service_api LANGUAGES CXX)
  include(CTest)
  set(CMAKE_CXX_STANDARD 20)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)

  set(CPPBOOSTSERVICELIB_SOURCE_DIR "" CACHE PATH
      "Path to a cppboostservicelib source checkout")
  set(CPPBOOSTSERVICELIB_DEPENDENCY_MODE "CONAN" CACHE STRING "" FORCE)
  set(CPPBOOSTSERVICELIB_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  if(CPPBOOSTSERVICELIB_SOURCE_DIR)
    add_subdirectory("${CPPBOOSTSERVICELIB_SOURCE_DIR}"
        "${CMAKE_BINARY_DIR}/_deps/cppboostservicelib-build" EXCLUDE_FROM_ALL)
  else()
    include(FetchContent)
    FetchContent_Declare(servicegen_servicelib
        GIT_REPOSITORY "https://github.com/gorundebug/cppboostservicelib.git"
        GIT_TAG "v0.2.31"
        GIT_SHALLOW TRUE)
    FetchContent_MakeAvailable(servicegen_servicelib)
  endif()
endif()

add_library(example_order_service_api INTERFACE)
target_compile_features(example_order_service_api INTERFACE cxx_std_20)
target_link_libraries(example_order_service_api INTERFACE servicelib::servicelib)
target_include_directories(example_order_service_api INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_sources(example_order_service_api INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/openapi/orderserviceapi/orderserviceapi.cpp.generated.yaml")