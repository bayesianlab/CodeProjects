# CREATE SAMPLE DATA library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(csdLib)
cmake_policy(SET CMP0042 NEW)
get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_HEADERS "/usr/local/include/eigen3/" )
set(BOOST_HEADERS "/usr/local/include/boost/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CODE_HOME "~/Google Drive/CodeProjects/CProjects/Simulation")


message(STATUS "Eigen Header Files     " ${EIGEN_HEADERS})
message(STATUS "Boost Directory        " ${BOOST_HEADERS})
message(STATUS "CProject Directory     " ${PARENT})
message(STATUS "Current WD             " ${CMAKE_CURRENT_SOURCE_DIR} )
include_directories(${EIGEN_HEADERS} ${BOOST_HEADERS} ${CODE_HOME}/include)

add_library(CreateSampleData STATIC ${CODE_HOME}/src/CreateSampleData.cpp)
install(TARGETS CreateSampleData DESTINATION ${CODE_HOME}/bin)
install(FILES ${CODE_HOME}/include/CreateSampleData.hpp DESTINATION ${CODE_HOME}/include)



