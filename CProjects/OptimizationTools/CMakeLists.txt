
add_library(fort STATIC src/fort.c)
target_include_directories(fort PRIVATE
    include/
)

set(optimsrc src/LineSearchRoutines.cpp src/NumericalDifferentiation.cpp src/Optimization.cpp)
add_library(optlib STATIC ${optimsrc})
target_include_directories(optlib PRIVATE include/
    ${EIGEN_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR})
add_executable(optimtest src/Test_Optimization.cpp)
target_link_libraries(optimtest PRIVATE optlib)

add_executable(tab src/tableau.cpp)
target_include_directories(tab PRIVATE include/ 
    ${EIGEN_INCLUDE_DIR} ${BOOST_INCLUDEDIR})
target_link_libraries(tab PRIVATE fort)
