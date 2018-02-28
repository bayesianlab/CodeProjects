# TOP LEVEL CMAKE
cmake_minimum_required(VERSION 2.8.9 FATAL_ERROR)
project(mvt)

set(EIGEN_DIR "/usr/local/include/eigen3/" )
set(BOOST_DIR "/usr/local/include/boost_1_66_0/")
set(CMAKE_CXX_STANDARD 11)
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS "-o3")

#add_subdirectory(build/src/DistLib)
add_subdirectory(build/src/CreateSampleDataLib)
#add_subdirectory(build/src/CrbLib)
add_subdirectory(build/src/AskLib)
add_subdirectory(build/src/ArkLib)
add_subdirectory(build/src/CrtLib)
add_subdirectory(build/src/ImpLib)
add_subdirectory(build/src/LinRegGibbsLib)
add_subdirectory(build/src/ReadCsvLib)

include_directories(include   ${EIGEN_DIR} ${BOOST_DIR})

add_executable(mvt src/rentalmain.cpp src/eigenshorts.cpp src/Dist.cpp src/Crb.cpp)
target_link_libraries(mvt CreateSampleData Ark Ask Crt Imp Lrg ReadCsv )
