# Top level cmake 
cmake_minimum_required(VERSION 3.20) 
project(build_all)

# Include custom configuration
include(cmake/cmake_config.cmake)

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

# Output Directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build)

# Subdirectories
add_subdirectory(GnuPlotting)
add_subdirectory(Distributions)
add_subdirectory(EigenTools)
add_subdirectory(TimeSeries)
add_subdirectory(OptimizationTools)
add_subdirectory(MultilevelModel)
add_subdirectory(MVProbit)

