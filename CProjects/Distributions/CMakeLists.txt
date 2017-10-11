cmake_minimum_required(VERSION 2.8.9)
project(sim)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost_1_64_0/")
set(CPROJECT_DIR "/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/")
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(SOURCES src/Dist.cpp src/ProbabilitySimulator.cpp src/MarginalLikelihoodCalculator.cpp src/mainchib.cpp 
	${CPROJECT_DIR}/CreateSampleData/src/CreateSampleData.cpp )

message(STATUS "Building Dist")
message(STATUS "Eigen Directory    " ${EIGEN_DIR})
message(STATUS "Boost Directory    " ${BOOST_DIR})
message(STATUS "CProject directory    " ${CPROJECT_DIR})

include_directories(include  ${EIGEN_DIR} ${BOOST_DIR} ${CPROJECT_DIR}/CreateSampleData/include)

add_executable(dist ${SOURCES})
