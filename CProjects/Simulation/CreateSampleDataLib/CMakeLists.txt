# CreateSampleData CMakeLists
cmake_minimum_required(VERSION 2.8.9)

project(csd)

cmake_policy(SET CMP0042 NEW)

get_filename_component(PARENT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(EIGEN_HEADERS "/usr/local/include/eigen3/" )
set(BOOST_HEADERS "/usr/local/include/boost/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set( CMAKE_BUILD_TYPE Release )



message(STATUS "Eigen Header Files     " ${EIGEN_HEADERS})
message(STATUS "Boost Directory        " ${BOOST_HEADERS})
message(STATUS "CProject Directory     " ${PARENT})
message(STATUS "Current WD             " ${CMAKE_CURRENT_SOURCE_DIR} )

include_directories( ${EIGEN_HEADERS} ${BOOST_HEADERS})

add_library(csd STATIC CreateSampleData.cpp CreateSampleData.hpp)
target_include_directories(csd PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(csd LINK_PUBLIC Dist)



