# For displaying tables
add_library(fort STATIC src/fort.c)
target_include_directories(fort PRIVATE
    include/
)

# Non linear optimization package
set(optimsrc src/LinearConstraint.cpp src/Objective.cpp src/Model.cpp src/Enums.cpp src/LineSearchRoutines.cpp BFGS/BFGS.cpp Differentiation/NumericalDifferentiation.cpp)
add_library(optlib STATIC ${optimsrc})
target_include_directories(optlib PRIVATE include/ BFGS/ Differentiation/ LineSearch/
    ${EIGEN_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR})

# Tests
add_executable(optimtest src/Test_Optimization.cpp)
target_link_libraries(optimtest PRIVATE optlib)
target_include_directories(optimtest PRIVATE 
    ${EIGEN_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
    include
    BFGS
    Differentiation
    LineSearch
)

# Linear Optimization Tests
add_executable(linopttest src/LinOptTests.cpp)
target_include_directories(linopttest PRIVATE 
    ${EIGEN_INCLUDE_DIR}
    ${BOOST_INCLUDEDIR}
    include
    BFGS
    Differentiation
    LineSearch
)
target_link_libraries(linopttest PRIVATE optlib fort GTest::gtest_main GTest::gtest)

# Simplex
add_executable(tab src/tableau.cpp)
target_include_directories(tab PRIVATE 
    include 
    ${EIGEN_INCLUDE_DIR} 
    ${BOOST_INCLUDEDIR}

)
target_link_libraries(tab PRIVATE fort)
