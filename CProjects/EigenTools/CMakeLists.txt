set(ettools src/EigenTools.cpp)
add_library(ettools STATIC ${ettools})
target_include_directories(ettools PRIVATE
    include
    ${EIGEN_INCLUDE_DIR}
    ${EIGEN_UNSUPPORTED_DIR})
# add_executable(ettest src/Test_EigenTools.cpp)
# target_link_libraries(ettest PUBLIC ettools)

