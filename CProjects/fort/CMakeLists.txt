project(fort)

# For displaying tables
add_library(fort STATIC fort.c)
target_include_directories(fort PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")