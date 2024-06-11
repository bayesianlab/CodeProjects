

# add_executable(mvp src/mvp.cpp src/test_mvp.cpp)
# target_link_libraries(mvp PUBLIC Dist ettools optlib ml) 

add_executable(mvpf src/test_mvpf.cpp)
target_link_libraries(mvpf PUBLIC Dist ettools optlib ml plot)

# add_executable(scr src/scratch.cpp)
# target_link_libraries(scr PUBLIC Dist ettools ml plot)