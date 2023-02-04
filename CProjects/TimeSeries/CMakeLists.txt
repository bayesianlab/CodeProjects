
add_executable(test_armodel src/Test_ArModel.cpp src/GenerateAutoRegressiveData.cpp)
target_link_libraries(test_armodel PUBLIC ettools Dist plot)

# add_executable(test_armodel2 src/test_armodel_nomean.cpp src/GenerateAutoRegressiveData.cpp)
# target_link_libraries(test_armodel2 PUBLIC ettools Dist plot)

# add_executable(test_mamodel src/Test_MAmodel.cpp)
# target_link_libraries(test_mamodel PUBLIC ettools Dist plot)


 
