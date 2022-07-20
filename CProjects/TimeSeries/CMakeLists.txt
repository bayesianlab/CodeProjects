
add_executable(tstest src/Test_ArModel.cpp src/GenerateAutoRegressiveData.cpp)
target_link_libraries(tstest PUBLIC ettools Dist plot)

 
