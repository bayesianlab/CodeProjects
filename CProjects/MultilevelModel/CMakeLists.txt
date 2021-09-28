# Top level cmake 
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(multilevel)

# set(CMAKE_BUILD_TYPE DEBUG)
set(CMAKE_BUILD_TYPE RELEASE)
set(CMAKE_CXX_FLAGS_REALEASE "-O3 -march=native -mfpmath=sse -funroll-loops")
message(STATUS ${CMAKE_CXX_FLAGS_REALEASE})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")

set(CMAKE_CXX_COMPILER_LAUNCHER ccache)

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

set(CODEPATH "/home/dillon/CodeProjects/CProjects")
set(eigentoolsrc ${CODEPATH}/EigenTools/src/EigenTools.cpp)
set(distsrc ${CODEPATH}/Distributions/src/Distributions.cpp)
set(optimsrc ${CODEPATH}/OptimizationTools/src/Optimization.cpp)
set(lssrc ${CODEPATH}/OptimizationTools/src/LineSearchRoutines.cpp)
set(numdiffsrc ${CODEPATH}/OptimizationTools/src/NumericalDifferentiation.cpp)
set(plotsrc ${CODEPATH}/GnuPlotting/src/Plotter.cpp)
set(ardatagensrc ${CODEPATH}/TimeSeries/src/GenerateAutoRegressiveData.cpp)

add_library(basetools STATIC ${plotsrc} ${eigentoolsrc} ${distsrc} ${optimsrc} ${lssrc} ${numdiffsrc})
add_library(mlfunc STATIC src/MultilevelModelFunctions.cpp)
add_library(datagen STATIC ${ardatagensrc} src/GenerateMLFactorData.cpp)
target_link_libraries(mlfunc PUBLIC basetools)
target_link_libraries(datagen PUBLIC basetools mlfunc)

set(tsfuncinclude ${CODEPATH}/TimeSeries/include)
set(eigentoolinclude ${CODEPATH}/EigenTools/include)
set(distinclude ${CODEPATH}/Distributions/include)
set(optiminclude ${CODEPATH}/OptimizationTools/include)
set(plotinclude ${CODEPATH}/GnuPlotting/include)

include_directories(${tsfuncinclude} ${plotinclude} ${eigentoolinclude} ${distinclude} ${optiminclude} include)

add_executable(test2 src/Test_MultilevelModel.cpp)
target_link_libraries(test2 PUBLIC basetools mlfunc datagen) 


