project(distlib)

add_library(distlib STATIC DistLib.cpp)
target_include_directories(distlib PUBLIC ${CMAKE_SOURCE_DIR}/Distributions)
target_link_libraries(distlib PUBLIC Eigen3::Eigen)

add_executable(test_distlib test_distlib.cpp)
target_link_libraries(test_distlib PRIVATE GTest::gtest_main GTest::gtest distlib)

add_executable(test_bayes 
    bayes_test.cpp 
    bayes.cpp)
target_link_libraries(test_bayes PRIVATE GTest::gtest_main GTest::gtest distlib)
target_include_directories(test_bayes PRIVATE Distributions)