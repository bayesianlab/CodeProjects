cmake_minimum_required(VERSION 2.8.9 FATAL_ERROR)
project(mvt)

get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_BUILD_TYPE Debug)


set(LIBS libDist.a)

set(SOURCES 
	src/crb.cpp
	src/ark.cpp
	src/crt.cpp
	src/ask.cpp
	src/LinRegGibbs.cpp
	src/Importance.cpp
	src/fixdist.cpp
	src/read_csv_to_eigen.cpp
	)

message(STATUS "Eigen Directory    " ${EIGEN_DIR})
message(STATUS "Boost Directory    " ${BOOST_DIR})
message(STATUS "CProject Directory    " ${PARENT})
include_directories(include ${EIGEN_DIR} ${BOOST_DIR})
link_directories(lib)
add_executable(mvt ${SOURCES})
target_link_libraries(mvt ${LIBS})
