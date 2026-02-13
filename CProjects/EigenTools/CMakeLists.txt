set(tools src/EigenTools.cpp)
add_library(tools STATIC ${tools})
target_include_directories(tools PRIVATE
    include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR})
# add_executable(ettest src/Test_EigenTools.cpp)
# target_link_libraries(ettest PUBLIC tools)

