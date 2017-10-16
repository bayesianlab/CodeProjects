cmake_minimum_required(VERSION 2.8.9)
project(crt)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost_1_64_0/")
set(CPROJECT_DIR "/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/")

set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

set(SOURCES 
	${CPROJECT_DIR}/Distributions/src/Dist.cpp 
	${CPROJECT_DIR}/CreateSampleData/src/CreateSampleData.cpp
	src/ask.cpp
	src/askmain.cpp
	)

message(STATUS "Eigen Directory    " ${EIGEN_DIR})
message(STATUS "Boost Directory    " ${BOOST_DIR})
message(STATUS "CProject directory    " ${CPROJECT_DIR})

include_directories(
	include
  	${EIGEN_DIR}
   	${BOOST_DIR}
	${CPROJECT_DIR}/CreateSampleData/include
	${CPROJECT_DIR}/Distributions/include 
	)

add_executable(ask ${SOURCES})
