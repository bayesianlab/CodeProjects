# Top level cmake 
cmake_minimum_required(VERSION 3.20...4.2) 

# Auto-detect vcpkg so `cmake ..` works without explicit toolchain flags.
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VCPKG_ROOT})
    set(_VCPKG_ROOT "$ENV{VCPKG_ROOT}")
  else()
    set(_VCPKG_ROOT "${CMAKE_SOURCE_DIR}/../vcpkg")
    if(NOT EXISTS "${_VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
      set(_VCPKG_ROOT "C:/Users/USER/vcpkg")
    endif()
  endif()

  if(EXISTS "${_VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    set(CMAKE_TOOLCHAIN_FILE "${_VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE FILEPATH "vcpkg toolchain file" FORCE)
    set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "vcpkg target triplet" FORCE)
  endif()
endif()

if(DEFINED CMAKE_TOOLCHAIN_FILE AND EXISTS "${CMAKE_TOOLCHAIN_FILE}")
  include("${CMAKE_TOOLCHAIN_FILE}")
endif()

# If the user runs plain `cmake ..` with a Visual Studio generator,
# default the generator platform to x64 to avoid mixing x86/vs libs.
if(CMAKE_GENERATOR MATCHES "Visual Studio" AND NOT DEFINED CMAKE_GENERATOR_PLATFORM)
  set(CMAKE_GENERATOR_PLATFORM "x64" CACHE STRING "Generator platform" FORCE)
  set(CMAKE_VS_PLATFORM_NAME "x64" CACHE STRING "VS platform name" FORCE)
endif()

project(build_all)


# Compiler and build settings
cmake_policy(SET CMP0091 NEW)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
  add_compile_options(/bigobj)
endif()

find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif(CCACHE_FOUND)

find_package(Boost REQUIRED)
if(Boost_FOUND)
  message(STATUS "Boost found")
else()
  message(STATUS "Boost NOT FOUND")
endif()

# Default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build" FORCE)
endif()

# Compiler-specific release flags
if(MSVC)
  set(CMAKE_CXX_FLAGS_RELEASE "/O2 /Ob2 /DNDEBUG /openmp")
  set(CMAKE_C_FLAGS_RELEASE "/O2 /Ob2 /DNDEBUG /openmp")
else()
  set(CMAKE_CXX_FLAGS_RELEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math")
  set(CMAKE_C_FLAGS_RELEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math")
endif()

# Export compile commands for tooling
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Boost settings
set(Boost_DEBUG OFF)

find_package(GTest REQUIRED)
if(GTest_FOUND)
  message(STATUS "GTest found")
else()
  message(STATUS "GTest NOT FOUND")
endif()

find_package(Eigen3 REQUIRED NO_MODULE)
if(Eigen3_FOUND)
  get_target_property(EIGEN3_INCLUDE_DIRS Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
  set(EIGEN_UNSUPPORTED "${EIGEN3_INCLUDE_DIRS}/unsupported")
  message(STATUS "Found Eigen3: ${Eigen3_DIR} -> ${EIGEN3_INCLUDE_DIRS}")
else()
  message(FATAL_ERROR "Eigen3 not found")
endif()
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
  target_include_directories(${target} PRIVATE ${EIGEN3_INCLUDE_DIRS})
endfunction()

# Apply to test targets
function(add_test_pch_to_target target)
  target_precompile_headers(${target} PRIVATE 
    ${CMAKE_BINARY_DIR}/pch_test.hpp)
  target_include_directories(${target} PRIVATE ${EIGEN3_INCLUDE_DIRS})
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
add_subdirectory(Calendar)

