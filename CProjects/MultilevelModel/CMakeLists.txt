# Top level cmake 
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project(multilevel)

set(mlsrc src/MultilevelModelFunctions.cpp src/GenerateFactorData.cpp )

add_library(ml STATIC ${mlsrc})
target_link_libraries(ml PUBLIC Dist ettools)
target_include_directories(ml PRIVATE 
  include
  ${EIGEN_INCLUDE_DIR}
  ${EIGEN_UNSUPPORTED_DIR}
  ${GCEM_INCLUDE_DIR}
  ${CMAKE_SOURCE_DIR}/Distributions/include
  ${CMAKE_SOURCE_DIR}/EigenTools/include
  ${CMAKE_SOURCE_DIR}/TimeSeries/include
  ${STATS_INCLUDE_DIR}
  ${BOOST_INCLUDEDIR}

)

# add_executable(test_fullconditionals src/test_fullconditionals.cpp)
# target_link_libraries(test_fullconditionals PUBLIC optim ettools plot Dist ml)

# add_executable(test_timebreak src/test_timebreak.cpp)
# target_link_libraries(test_timebreak PUBLIC optlib ettools plot Dist ml)

# add_executable(test_fullconditionalsnoar src/test_fullconditionalsnoar.cpp)
# target_link_libraries(test_fullconditionalsnoar PUBLIC optim ettools plot Dist ml)
