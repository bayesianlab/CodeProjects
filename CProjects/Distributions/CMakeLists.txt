project(Distributions)


add_library(Dist STATIC src/Distributions.cpp)

target_link_libraries(Dist PUBLIC 
    Eigen3::Eigen)
add_pch_to_target(Dist)

target_include_directories(Dist PUBLIC
    include
    ${CMAKE_SOURCE_DIR}/gcem/include
    ${CMAKE_SOURCE_DIR}/stats/include
    ${EIGEN_UNSUPPORTED}
    ${CMAKE_SOURCE_DIR}/EigenTools/include
    ${STATS_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)
# add_executable(disttest src/Test_Distributions.cpp)
# include_directories(Dist /home/dillon/stats) 
# target_link_libraries(disttest PUBLIC Dist plot)
