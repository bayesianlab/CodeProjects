cmake_minimum_required(VERSION 3.22) 
project(nnet)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)



add_executable(net src/ann.cpp)
target_link_libraries(net PRIVATE 
  Dist 
  tools 
  plot
  Eigen3::Eigen)
add_pch_to_target(net)