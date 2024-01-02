
cmake_minimum_required(VERSION 3.22) 
project(simplex)
set(CMAKE_BUILD_TYPE DEBUG)
find_package(Boost)
if(Boost_FOUND)
  include_directories(${Boost_INCLUDE_DIRS})
  message(STATUS "Found boost headers")
endif(Boost_FOUND)

set(optimsrc src/LineSearchRoutines.cpp src/NumericalDifferentiation.cpp src/Optimization.cpp)
add_library(optlib STATIC ${optimsrc})
target_include_directories(optlib PUBLIC include/ /usr/local/include/eigen-3.4.0)
add_executable(optimtest src/Test_Optimization.cpp)
target_link_libraries(optimtest PUBLIC optlib)



add_executable(tab src/tableau.cpp)
target_include_directories(tab PUBLIC include/ /usr/local/include/eigen-3.4.0)
