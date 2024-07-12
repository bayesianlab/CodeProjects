set(plot ${CMAKE_CURRENT_SOURCE_DIR}/src/Plotter.cpp)
add_library(plot STATIC ${plot})
target_link_libraries(plot PUBLIC ettools)
