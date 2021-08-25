# TOP LEVEL CMAKE
cmake_minimum_required(VERSION 2.8.9 FATAL_ERROR)
project(mvt)

find_package(Boost  REQUIRED)
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_BUILD_TYPE Release)
set(EIGEN "/usr/local/include/eigen3")
set(UNSUPP "/usr/local/include/eigen3/unsupported")
set(CMAKE_CXX_FLAGS "-O3")
set(SIM "/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/")

include_directories(include ${SIM}/include ${BOOST_INCLUDE_DIRS} ${EIGEN} ${UNSUPP})
message(STATUS "Boost include  dirs  " ${Boost_INCLUDE_DIRS})
MESSAGE( STATUS "CMAKE_CXX_FLAGS:    " ${CMAKE_CXX_FLAGS} )
message(STATUS "Eigen3 dir           " ${EIGEN})
add_executable(mvt src/probitmain.cpp src/Probit.cpp ${SIM}/src/Dist.cpp ) 
