cmake_minimum_required(VERSION 2.8.9)
project(crt)

get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

set(SOURCES 
	${PARENT}/Distributions/src/Dist.cpp 
	${PARENT}/CreateSampleData/src/CreateSampleData.cpp
	src/crt.cpp
	src/crtml.cpp
	)

message(STATUS "Eigen Directory    " ${EIGEN_DIR})
message(STATUS "Boost Directory    " ${BOOST_DIR})
message(STATUS "CProject Directory    " ${PARENT})

include_directories(
	include
  	${EIGEN_DIR}
   	${BOOST_DIR}
	${PARENT}/CreateSampleData/include
	${PARENT}/Distributions/include 
	)

add_executable(crt ${SOURCES})
