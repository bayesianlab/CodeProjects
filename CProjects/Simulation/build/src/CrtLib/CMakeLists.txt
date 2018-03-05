# CRT library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(crtlibrary)
cmake_policy(SET CMP0042 NEW)

find_package(Boost 1.66.0 REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CMAKE_CXX_FLAGS "-o3")

include_directories(${CMAKE_SOURCE_DIR}/include ${Eigen_INCLUDE_DIRS} ${BOOST_INCLUDE_DIRS})

add_library(Crt STATIC ${CMAKE_SOURCE_DIR}/src/crt.cpp)
install(TARGETS Crt DESTINATION ${CMAKE_SOURCE_DIR}/bin)
install(FILES ${CMAKE_SOURCE_DIR}/include/crt.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include)


