# CRT library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(crtlibrary)
cmake_policy(SET CMP0042 NEW)
get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_HEADERS "/usr/local/include/eigen3/" )
set(BOOST_HEADERS "/usr/local/include/boost/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CODE_HOME "~/Google Drive/CodeProjects/CProjects/Simulation")
include_directories(${EIGEN_HEADERS} ${BOOST_HEADERS} ${CODE_HOME}/include)
add_library(Crt STATIC ${CODE_HOME}/src/crt.cpp)
install(TARGETS Crt DESTINATION ${CODE_HOME}/bin)
install(FILES ${CODE_HOME}/include/crt.hpp DESTINATION ${CODE_HOME}/include)


