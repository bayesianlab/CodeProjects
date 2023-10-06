set(ettools ${CMAKE_CURRENT_SOURCE_DIR}/src/EigenTools.cpp)
add_library(ettools STATIC ${ettools})
target_include_directories(ettools PUBLIC include)
add_executable(ettest src/Test_EigenTools.cpp)
target_link_libraries(ettest PUBLIC ettools)

