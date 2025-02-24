# Top level cmake 
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project(multilevel)
# set(CMAKE_CXX_STANDARD 11)
set(CMAKE_BUILD_TYPE DEBUG)
#  set(CMAKE_BUILD_TYPE RELEASE)
#  set(CMAKE_CXX_FLAGS_REALEASE "-O3 -march=native -mfpmath=sse -funroll-loops -fopenmp -DNDEBUG -ffast-math -j")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# add_compile_options(-Wall -Wextra -pedantic)
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  message(STATUS "Found CCACHE")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) 
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif(CCACHE_FOUND)
set(mlsrc src/MultilevelModelFunctions.cpp src/GenerateFactorData.cpp )

add_library(ml STATIC ${mlsrc})
target_link_libraries(ml PUBLIC Dist ettools)

# add_executable(test_fullconditionals src/test_fullconditionals.cpp)
# target_link_libraries(test_fullconditionals PUBLIC optim ettools plot Dist ml)

# add_executable(test_timebreak src/test_timebreak.cpp)
# target_link_libraries(test_timebreak PUBLIC optlib ettools plot Dist ml)

# add_executable(test_fullconditionalsnoar src/test_fullconditionalsnoar.cpp)
# target_link_libraries(test_fullconditionalsnoar PUBLIC optim ettools plot Dist ml)
