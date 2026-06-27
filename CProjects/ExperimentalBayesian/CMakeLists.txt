
add_executable(bayes_test 
    bayes_test.cpp 
    bayes.cpp)
target_link_libraries(bayes_test PRIVATE GTest::gtest_main GTest::gtest Dist)