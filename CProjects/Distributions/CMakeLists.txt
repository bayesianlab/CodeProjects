set(distsrc ${CMAKE_CURRENT_SOURCE_DIR}/src/Distributions.cpp)
add_library(Dist STATIC ${distsrc})
add_executable(disttest src/Test_Distributions.cpp)
target_link_libraries(disttest PUBLIC Dist plot)