set(mlsrc src/MultilevelModelFunctions.cpp src/GenerateFactorData.cpp )
add_library(ml STATIC ${mlsrc})
target_link_libraries(ml PUBLIC Dist ettools)

add_executable(test_fullconditionals src/test_fullconditionals.cpp)
target_link_libraries(test_fullconditionals PUBLIC optim ettools plot Dist ml)

add_executable(test_timebreak src/test_timebreak.cpp)
target_link_libraries(test_timebreak PUBLIC optim ettools plot Dist ml)

# add_executable(test_fullconditionalsnoar src/test_fullconditionalsnoar.cpp)
# target_link_libraries(test_fullconditionalsnoar PUBLIC optim ettools plot Dist ml)