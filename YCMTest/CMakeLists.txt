# TOP LEVEL CMAKE
cmake_minimum_required(VERSION 2.8.9 FATAL_ERROR)
project(mvt)

find_package(Boost  REQUIRED)
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_BUILD_TYPE Debug)
set(EIGEN "/usr/local/include/eigen3")

include_directories(include  ${BOOST_INCLUDE_DIRS} ${EIGEN})
message(STATUS "Boost include  dirs  " ${Boost_INCLUDE_DIRS})
MESSAGE( STATUS "CMAKE_CXX_FLAGS:    " ${CMAKE_CXX_FLAGS} )
message(STATUS "Eigen3 dir           " ${EIGEN})
add_executable(mvt src/testmain.cpp )
