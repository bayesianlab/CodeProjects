set(distsrc src/Distributions.cpp)
add_library(Dist STATIC ${distsrc})
target_include_directories(Dist PRIVATE
    include
    ${GCEM_INCLUDE_DIR}
    ${CMAKE_SOURCE_DIR}/EigenTools/include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR}
    ${STATS_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
)
# add_executable(disttest src/Test_Distributions.cpp)
# include_directories(Dist /home/dillon/stats) 
# target_link_libraries(disttest PUBLIC Dist plot)
