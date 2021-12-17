set(mlsrc src/MultilevelModelFunctions.cpp src/GenerateMLFactorData.cpp)
add_library(ml STATIC ${mlsrc})
# add_executable(test_otrok src/Test_otrok.cpp)
# target_link_libraries(test_otrok PUBLIC ettools plot Dist ml) 
# add_executable(tb_noworld src/tb_noworld.cpp)
# target_link_libraries(tb_noworld PUBLIC ettools  Dist ml) 
add_executable(tb src/tb.cpp)
target_link_libraries(tb PUBLIC ettools  Dist ml) 
# add_executable(wo src/worldonly.cpp)
# target_link_libraries(wo PUBLIC ettools  Dist ml) 
# add_executable(testml src/Test_MultilevelModel.cpp)
# target_link_libraries(testml PUBLIC optim ettools plot Dist ml)


