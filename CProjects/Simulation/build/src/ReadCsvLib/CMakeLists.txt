# Read CSV library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(readcsvlibrary)
cmake_policy(SET CMP0042 NEW)
get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CMAKE_CXX_FLAGS "-O3")
set(EIGEN "/usr/local/include/eigen3/Eigen")
include_directories(${CMAKE_SOURCE_DIR}/include ${EIGEN})

add_library(ReadCsv STATIC ${CMAKE_SOURCE_DIR}/src/read_csv_to_eigen.cpp)
install(TARGETS ReadCsv DESTINATION ${CMAKE_SOURCE_DIR}/bin)
install(FILES ${CMAKE_SOURCE_DIR}/include/read_csv_to_eigen.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include)


