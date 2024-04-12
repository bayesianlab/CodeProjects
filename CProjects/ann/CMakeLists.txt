cmake_minimum_required(VERSION 3.22) 
project(ann)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE DEBUG)
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
set(MYINCLUDES /home/dillon/CodeProjects/CProjects)
include_directories(
  ${MYINCLUDES}/EigenTools/include
  ${MYINCLUDES}/Distributions/include 
  ${MYINCLUDES}/TimeSeries/include
  ${MYINCLUDES}/GnuPlotting/include
  ${MYINCLUDES}/MultilevelModel/include
  ${MYINCLUDES}/OptimizationTools/include
  # ${CMAKE_CURRENT_SOURCE_DIR}/MVProbit/include
  /usr/local/include/stats-master/include
  /usr/local/include/gcem-master/include 
  /usr/local/include/eigen-3.4.0 
  /usr/local/include/eigen-3.4.0/unsupported
  )
add_library(Dist /home/dillon/CodeProjects/CProjects/Distributions/src/Distributions.cpp)
add_library(et ${MYINCLUDES}/EigenTools/src/EigenTools.cpp)

add_executable(ann ann.cpp)
target_link_libraries(ann PUBLIC Dist et)