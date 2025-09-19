
add_library(plot STATIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Plotter.cpp)
target_link_libraries(plot PUBLIC ettools)
target_include_directories(plot PRIVATE 
    include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR}
    ${BOOST_INCLUDEDIR}
    ${CMAKE_SOURCE_DIR}/EigenTools/include
)