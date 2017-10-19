cmake_minimum_required(VERSION 2.8.9)
project(ark)

get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost_1_64_0/")

set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

set(SOURCES 
	${PARENT}/Distributions/src/Dist.cpp 
	${PARENT}/CreateSampleData/src/CreateSampleData.cpp
	src/ark.cpp
	src/arkmain.cpp
	)

message(STATUS "Eigen Directory    " ${EIGEN_DIR})
message(STATUS "Boost Directory    " ${BOOST_DIR})
message(STATUS "CProject directory    " ${CPROJECT_DIR})
message(STATUS "UP one level "${PAR})

include_directories(
	include
  	${EIGEN_DIR}
   	${BOOST_DIR}
	${PARENT}/CreateSampleData/include
	${PARENT}/Distributions/include 
	)

add_executable(ark ${SOURCES})
