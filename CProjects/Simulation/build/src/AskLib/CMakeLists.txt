# ASK library CMakeList.txt
cmake_minimum_required(VERSION 2.8.9)
project(asklibrary)
cmake_policy(SET CMP0042 NEW)

find_package(Boost  REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )
set(CMAKE_CXX_FLAGS "-o3")

include_directories(${CMAKE_SOURCE_DIR}/include ${Eigen_INCLUDE_DIRS} ${BOOST_INCLUDE_DIRS})

add_library(Ask STATIC ${CMAKE_SOURCE_DIR}/src/ask.cpp)
install(TARGETS Ask DESTINATION ${CMAKE_SOURCE_DIR}/bin)
install(FILES ${CMAKE_SOURCE_DIR}/include/ask.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include)


