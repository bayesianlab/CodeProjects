

add_executable(mvp src/mvp.cpp src/test_mvp.cpp)
target_link_libraries(mvp PUBLIC Dist ettools optlib ml) 