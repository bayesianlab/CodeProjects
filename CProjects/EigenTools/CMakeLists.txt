project(eigentools)

set(tools src/EigenTools.cpp)
message(STATUS "${EIGEN3_INCLUDE_DIR}")
add_library(tools STATIC ${tools})
target_include_directories(tools PRIVATE
    include
    ${EIGEN_UNSUPPORTED})
target_link_libraries(tools PRIVATE Eigen3::Eigen)
add_pch_to_target(tools)
# add_executable(ettest src/Test_EigenTools.cpp)
# target_link_libraries(ettest PUBLIC tools)

