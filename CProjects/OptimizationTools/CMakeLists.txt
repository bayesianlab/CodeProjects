set(optimsrc src/LineSearchRoutines.cpp src/NumericalDifferentiation.cpp src/Optimization.cpp)
add_library(optim STATIC ${optimsrc})
add_executable(optimtest src/Test_Optimization)
target_link_libraries(optimtest PUBLIC optim)
