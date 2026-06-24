project(plotter)

add_library(plot STATIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Plotter.cpp)
target_link_libraries(plot PUBLIC 
    tools
    Eigen3::Eigen)
add_pch_to_target(plot)
target_include_directories(plot PUBLIC 
    include
    ${Boost_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/EigenTools/include
    ${EIGEN_UNSUPPORTED})