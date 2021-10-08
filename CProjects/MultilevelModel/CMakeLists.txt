# Top level cmake 
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(multilevel)

# set(CMAKE_BUILD_TYPE DEBUG)
set(CMAKE_BUILD_TYPE RELEASE)
set(CMAKE_CXX_FLAGS_REALEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# add_compile_options(-Wall -Wextra -pedantic)
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) 
endif(CCACHE_FOUND)


# message(STATUS ${CMAKE_CXX_FLAGS_REALEASE})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")

set(CMAKE_CXX_COMPILER_LAUNCHER ccache)

find_package(Eigen3)
if (${EIGEN3_FOUND})
  include_directories(${EIGEN3_INCLUDE_DIR})
else()
  message(STATUS "Eigen3 not found")
endif()
find_package(Boost REQUIRED COMPONENTS filesystem)
if(Boost_FOUND)
  include_directories(${Boost_INCLUDE_DIRS})
  message(STATUS "Found boost headers")
endif(Boost_FOUND)

set(CODEPATH "/home/dillon/CodeProjects/CProjects")
set(eigentoolsrc ${CODEPATH}/EigenTools/src/EigenTools.cpp)
set(distsrc ${CODEPATH}/Distributions/src/Distributions.cpp)
set(optimsrc ${CODEPATH}/OptimizationTools/src/Optimization.cpp)
set(lssrc ${CODEPATH}/OptimizationTools/src/LineSearchRoutines.cpp)
set(numdiffsrc ${CODEPATH}/OptimizationTools/src/NumericalDifferentiation.cpp)
set(plotsrc ${CODEPATH}/GnuPlotting/src/Plotter.cpp)
set(ardatagensrc ${CODEPATH}/TimeSeries/src/GenerateAutoRegressiveData.cpp)

add_library(basetools STATIC ${distsrc} ${plotsrc} ${eigentoolsrc})
add_library(optim STATIC  ${optimsrc} ${lssrc} ${numdiffsrc})
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
# add_executable(test2 src/scratch.cpp)
# add_executable(test2 ../TimeSeries/src/Test_ArModel.cpp)
# add_executable(test2 ../EigenTools/src/Test_EigenTools.cpp)
target_link_libraries(test2 PUBLIC datagen basetools optim mlfunc) 


