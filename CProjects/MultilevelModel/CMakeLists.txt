# Top level cmake 
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(multilevel)

set(CMAKE_BUILD_TYPE DEBUG)
# set(CMAKE_BUILD_TYPE RELEASE)
# set(CMAKE_CXX_FLAGS_REALEASE "-O3 -march=native -mfpmath=sse -funroll-loops")
# message(STATUS ${CMAKE_CXX_FLAGS_REALEASE})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")

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


add_library(optim STATIC  /home/dillon/CodeProjects/CProjects/OptimizationTools/src/Optimization.cpp /home/dillon/CodeProjects/CProjects/OptimizationTools/src/LineSearchRoutines.cpp /home/dillon/CodeProjects/CProjects/OptimizationTools/src/NumericalDifferentiation.cpp)
add_library(dist STATIC /home/dillon/CodeProjects/CProjects/Distributions/src/Distributions.cpp)
add_library(plot STATIC /home/dillon/CodeProjects/CProjects/GnuPlotting/src/Plotter.cpp)
add_library(mlfunc STATIC src/MultilevelModelFunctions.cpp)
add_library(mylib src/GenerateMLFactorData.cpp src/GenerateAutoRegressiveData.cpp)
target_link_libraries(mylib mlfunc)
include_directories(/home/dillon/CodeProjects/CProjects/Distributions/include /home/dillon/CodeProjects/CProjects/OptimizationTools/include /home/dillon/CodeProjects/CProjects/GnuPlotting/include include)


add_executable(test2 src/Test_MultilevelModel.cpp )
target_link_libraries(test2 PUBLIC mylib optim dist plot) 
