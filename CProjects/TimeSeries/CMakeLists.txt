
# add_executable(test_armodel src/Test_ArModel.cpp src/GenerateAutoRegressiveData.cpp)
# target_link_libraries(test_armodel PUBLIC ettools Dist plot)

# add_executable(test_armodel2 src/test_armodel_nomean.cpp src/GenerateAutoRegressiveData.cpp)
# target_link_libraries(test_armodel2 PUBLIC ettools Dist plot)

# add_executable(test_mamodel src/Test_MAmodel.cpp)
# target_link_libraries(test_mamodel PUBLIC ettools Dist plot)

add_executable(tv src/testvar.cpp)
target_link_libraries(tv PUBLIC Dist Eigen3::Eigen)
add_pch_to_target(tv)
target_include_directories(tv PRIVATE
    include
    ${CMAKE_SOURCE_DIR}/gcem/include
    ${CMAKE_SOURCE_DIR}/stats/include
    ${EIGEN_UNSUPPORTED}
    ${BOOST_INCLUDEDIR}
    ${CMAKE_SOURCE_DIR}/Distributions/include
    ${CMAKE_SOURCE_DIR}/EigenTools/include
)


 
