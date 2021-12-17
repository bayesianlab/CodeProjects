set(plot ${CMAKE_CURRENT_SOURCE_DIR}/src/Plotter.cpp)
add_library(plot STATIC ${plot})
target_include_directories(plot PUBLIC include)
