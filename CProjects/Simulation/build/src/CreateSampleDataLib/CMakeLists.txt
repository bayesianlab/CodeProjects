# CREATE SAMPLE DATA library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(csdLib)
cmake_policy(SET CMP0042 NEW)

set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CMAKE_CXX_FLAGS "-O3")

include_directories(${CMAKE_SOURCE_DIR}/include )

add_library(CreateSampleData STATIC ${CMAKE_SOURCE_DIR}/src/CreateSampleData.cpp)
install(TARGETS CreateSampleData DESTINATION ${CMAKE_SOURCE_DIR}/bin)
install(FILES ${CMAKE_SOURCE_DIR}/include/CreateSampleData.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include)



