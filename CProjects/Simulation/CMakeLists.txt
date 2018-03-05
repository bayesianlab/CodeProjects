# TOP LEVEL CMAKE
cmake_minimum_required(VERSION 2.8.9 FATAL_ERROR)
project(mvt)

find_package(Boost  REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS "-o3")

add_subdirectory(build/src/DistLib)
add_subdirectory(build/src/CreateSampleDataLib)
add_subdirectory(build/src/CrbLib)
add_subdirectory(build/src/AskLib)
add_subdirectory(build/src/ArkLib)
add_subdirectory(build/src/CrtLib)
add_subdirectory(build/src/ImpLib)
add_subdirectory(build/src/LinRegGibbsLib)
add_subdirectory(build/src/ReadCsvLib)

include_directories(include ${Eigen3_INCLUDE_DIRS} ${BOOST_INCLUDE_DIRS})
message(STATUS "EIGEN CONFIG FILE " ${Eigen3_DIR})
message(STATUS "BOOST INCLUDE  DIRECTORIES " ${Boost_INCLUDE_DIRS})

add_executable(mvt src/rentalmain.cpp src/eigenshorts.cpp )
target_link_libraries(mvt Dist Crb CreateSampleData Ark Ask Crt Imp Lrg ReadCsv Eigen3::Eigen)
