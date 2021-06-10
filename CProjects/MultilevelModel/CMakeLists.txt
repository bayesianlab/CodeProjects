# Top level cmake 
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(multilevel)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")
set(CODE_PATH "/home/dillon/CodeProjects/CProjects")

find_package(Eigen3)
if (${EIGEN3_FOUND})
  include_directories(${EIGEN3_INCLUDE_DIR})
else()
  message(STATUS "Eigen3 not found")
endif()
find_package(Python3 COMPONENTS Interpreter Development)
if (${Python3_FOUND})
  include_directories(${Python3_INCLUDE_DIRS})
else()
  message(FATAL_ERROR "Python3 not found, please install it.")
endif()

include_directories(/usr/local/lib/python3.8/dist-packages/numpy/core/include)


add_library(mylibs src/Distributions.cpp src/Optimization.cpp include/Distributions.hpp include/Optimization.hpp)
target_include_directories(mylibs PUBLIC src/ include/)

add_executable(out src/test.cpp)
target_link_libraries(out PRIVATE ${Python3_LIBRARIES} mylibs)
