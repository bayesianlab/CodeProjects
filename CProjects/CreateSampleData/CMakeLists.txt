cmake_minimum_required(VERSION 2.8.9)
project(sampleData)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost_1_64_0/")
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(DIST_DIR /Users/dillonflannery-valadez/Google\ Drive/CodeProjects/CProjects/Distributions/)
set(SOURCES src/CreateSampleData.cpp src/main.cpp ${DIST_DIR}/src/Dist.cpp ) 

message(STATUS "Create Sample Data")
message(STATUS "Eigen directory    " ${EIGEN_DIR})
message(STATUS "Boost directory    " ${BOOST_DIR})
message(STATUS "Dist directory    " ${DIST_DIR})

include_directories(include  ${EIGEN_DIR} ${BOOST_DIR} ${DIST_DIR}/include)

add_executable(csd ${SOURCES})
