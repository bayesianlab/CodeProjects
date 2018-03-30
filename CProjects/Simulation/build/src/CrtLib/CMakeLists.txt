# CRT library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(crtlibrary)
cmake_policy(SET CMP0042 NEW)

set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CMAKE_CXX_FLAGS "-O3")
set(EIGEN "/usr/local/include/eigen3/Eigen")

include_directories(${CMAKE_SOURCE_DIR}/include ${EIGEN})

add_library(Crt STATIC ${CMAKE_SOURCE_DIR}/src/crt.cpp)
install(TARGETS Crt DESTINATION ${CMAKE_SOURCE_DIR}/bin)
install(FILES ${CMAKE_SOURCE_DIR}/include/crt.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include)


