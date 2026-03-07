# Top level cmake 
cmake_minimum_required(VERSION 3.20...4.2) 
project(build_all)


find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) 
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif(CCACHE_FOUND)

find_package(Boost)
if(Boost_FOUND)
  message(STATUS "Boost found")
endif()

# Compiler and build settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
  add_compile_options(/bigobj)
endif()

# Default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build" FORCE)
endif()

# Release flags
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math -j")


# Output Directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build)

# Export compile commands for tooling
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Boost settings
set(Boost_DEBUG OFF)

find_package(Boost 1.76.0 REQUIRED)
if(Boost_FOUND)
  message(STATUS "Boost found")
else()
  message(STATUS "Boost NOT FOUND")
endif()

set(EIGEN_UNSUPPORTED ${EIGEN3_INCLUDE_DIR}/unsupported)

find_package(GTest REQUIRED)
if(GTest_FOUND)
  message(STATUS "GTest found")
else()
  message(STATUS "GTest NOT FOUND")
endif()

# Use ccache if available
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) 
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif(CCACHE_FOUND)

find_package(Eigen3 3.3 REQUIRED NO_MODULE)
if(Eigen3_FOUND)
  set(EIGEN_UNSUPPORTED ${EIGEN3_INCLUDE_DIR}/unsupported)
  message(STATUS "Found Eigen3: ${Eigen3_DIR}")
else()
  message(FATAL_ERROR "Eigen3 not found")
endif()

find_package(Boost 1.76.0 REQUIRED)
file(WRITE "${CMAKE_BINARY_DIR}/pch_core.hpp"
"#pragma once
#include <Eigen/Dense>
#include <vector>
#include <map>
#include <unordered_map>
#include <algorithm>
#include <functional>
#include <memory>
#include <iostream>
#include <cmath>
#include <limits>
#include <numeric>
#include <stdexcept>
"
)

add_library(pch_core OBJECT IMPORTED)
set_source_files_properties(
  ${CMAKE_BINARY_DIR}/pch_core.hpp
  PROPERTIES LANGUAGE CXX
)
file(WRITE "${CMAKE_BINARY_DIR}/pch_test.hpp"
"#pragma once
#include <gtest/gtest.h>
#include <Eigen/Dense>
#include <vector>
#include <cmath>
#include <iostream>
"
)

# Apply to all library targets
function(add_pch_to_target target)
  target_precompile_headers(${target} PRIVATE 
    ${CMAKE_BINARY_DIR}/pch_core.hpp)
  target_include_directories(${target} PRIVATE ${EIGEN3_INCLUDE_DIR})
endfunction()

# Apply to test targets
function(add_test_pch_to_target target)
  target_precompile_headers(${target} PRIVATE 
    ${CMAKE_BINARY_DIR}/pch_test.hpp)
  target_include_directories(${target} PRIVATE ${EIGEN3_INCLUDE_DIR})
endfunction()

# Subdirectories
add_subdirectory(GnuPlotting)
add_subdirectory(Distributions)
add_subdirectory(EigenTools)
add_subdirectory(TimeSeries)
add_subdirectory(Optimization)
add_subdirectory(MultilevelModel)
add_subdirectory(MVProbit)
add_subdirectory(ann)
add_subdirectory(fort)
add_subdirectory(PracticeCode)

