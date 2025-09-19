

# add_executable(mvp src/mvp.cpp src/test_mvp.cpp)
# target_link_libraries(mvp PUBLIC Dist ettools optlib ml) 

# add_executable(mvpf src/test_mvpf.cpp)
# target_link_libraries(mvpf PUBLIC Dist ettools optlib ml plot)

# add_executable(mvpf src/test_mvpf.cpp)
# target_link_libraries(mvpf PUBLIC Dist ettools optlib ml plot)

# add_executable(scr src/scratch.cpp)
# target_link_libraries(scr PUBLIC Dist ettools ml plot)

# add_executable(tnorm src/truncated_normal_tests.cpp)
# target_link_libraries(tnorm PUBLIC Dist ettools ml plot)

add_executable(fps src/factor_probit_sims.cpp)
target_link_libraries(fps PRIVATE Dist ettools ml plot optlib)
target_include_directories(fps PRIVATE 
    include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR}
    ${GCEM_INCLUDE_DIR}
    ${STATS_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
    ${CMAKE_SOURCE_DIR}/MultilevelModel/include
    ${CMAKE_SOURCE_DIR}/TimeSeries/include
    ${CMAKE_SOURCE_DIR}/EigenTools/include
    ${CMAKE_SOURCE_DIR}/Distributions/include
    ${CMAKE_SOURCE_DIR}/Distributions/include
    ${CMAKE_SOURCE_DIR}/GnuPlotting/include
    ${CMAKE_SOURCE_DIR}/OptimizationTools/include
    )

add_executable(rp src/recession_prob.cpp)
target_link_libraries(rp PRIVATE Dist ettools ml plot optlib)
target_include_directories(rp PRIVATE
    include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR}
    ${GCEM_INCLUDE_DIR}
    ${STATS_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
    ${CMAKE_SOURCE_DIR}/MultilevelModel/include
    ${CMAKE_SOURCE_DIR}/TimeSeries/include
    ${CMAKE_SOURCE_DIR}/EigenTools/include
    ${CMAKE_SOURCE_DIR}/Distributions/include
    ${CMAKE_SOURCE_DIR}/Distributions/include
    ${CMAKE_SOURCE_DIR}/GnuPlotting/include
    ${CMAKE_SOURCE_DIR}/OptimizationTools/include
)