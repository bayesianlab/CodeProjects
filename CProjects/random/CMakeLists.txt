# Top level cmake 
cmake_minimum_required(VERSION 3.22) 
project(random)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE DEBUG)
#  set(CMAKE_BUILD_TYPE RELEASE)
#  set(CMAKE_CXX_FLAGS_REALEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math -j")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#add_compile_options(-Wall -Wextra -pedantic)
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) 
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif(CCACHE_FOUND)

find_package(Boost)
if(Boost_FOUND)
  include_directories(${Boost_INCLUDE_DIRS})
  message(STATUS "Found boost headers")
endif(Boost_FOUND)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build)

include_directories(
  /usr/local/include/stats-master/include
  /usr/local/include/gcem-master/include
  /usr/local/include/eigen-3.4.0/unsupported
  /usr/local/include/eigen-3.4.0
  ../EigenTools/include
  ../Distributions/include
)

add_library(Dist ../Distributions/src/Distributions.cpp)
add_library(et ../EigenTools/src/EigenTools.cpp)
target_link_libraries(et PUBLIC Dist)

add_executable(op optimize.cpp)
target_link_libraries(op Dist)


