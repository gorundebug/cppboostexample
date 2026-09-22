cmake_minimum_required(VERSION 3.24)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(example_model LANGUAGES CXX)
  include(CTest)
  set(CMAKE_CXX_STANDARD 20)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

add_library(example_model INTERFACE)
target_include_directories(example_model INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/include")