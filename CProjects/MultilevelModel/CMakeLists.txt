set(mlsrc src/MultilevelModelFunctions.cpp src/GenerateFactorData.cpp )
add_library(ml STATIC ${mlsrc})
target_link_libraries(ml PUBLIC Dist ettools)

# add_executable(test_fullconditionals src/test_fullconditionals.cpp)
# target_link_libraries(test_fullconditionals PUBLIC optim ettools plot Dist ml)

# add_executable(test_fullconditionalsnoar src/test_fullconditionalsnoar.cpp)
# target_link_libraries(test_fullconditionalsnoar PUBLIC optim ettools plot Dist ml)

add_executable(fullcond src/fullcond.cpp)
target_link_libraries(fullcond PUBLIC optim ettools plot Dist ml)

add_executable(fullcondnoar src/fullcondnoar.cpp)
target_link_libraries(fullcondnoar PUBLIC optim ettools plot Dist ml)

# add_executable(tutorial_fullcond src/tutorial_fullcond.cpp)
# target_link_libraries(tutorial_fullcond PUBLIC optim ettools plot Dist ml)

