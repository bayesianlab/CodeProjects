project(optimization)

# Non linear optimization package
set(bfgssrc 
    NonLinOpt/LineSearchRoutines.cpp 
    NonLinOpt/BFGS.cpp 
    NonLinOpt/NumericalDifferentiation.cpp)
add_library(optlib STATIC ${bfgssrc})
target_include_directories(optlib PUBLIC 
    NonLinOpt/ 
    ${Boost_INCLUDE_DIRS})
target_link_libraries(optlib PUBLIC Eigen3::Eigen)
add_pch_to_target(optlib)

# Tests
add_executable(bfgstest NonLinOpt/Test_Optimization.cpp)
target_link_libraries(bfgstest PRIVATE optlib Eigen3::Eigen)
add_pch_to_target(bfgstest)
target_include_directories(bfgstest PRIVATE 
    ${EIGEN3_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    NonLinOpt
)

set(linconstroptsrc 
    LinConstrOpt/src/LinearConstraint.cpp
    LinConstrOpt/src/Enums.cpp
    LinConstrOpt/src/Model.cpp
    LinConstrOpt/src/Objective.cpp
    LinConstrOpt/src/Variables.cpp)

add_library(linconstropt STATIC ${linconstroptsrc})
target_include_directories(linconstropt PRIVATE 
    LinConstrOpt/include    
    ${EIGEN3_INCLUDE_DIRS}/unsupported
)
target_link_libraries(linconstropt PRIVATE Eigen3::Eigen)
add_pch_to_target(linconstropt)

# Linear Optimization Tests
add_executable(linopttest 
    LinConstrOpt/src/LinOptTests.cpp
    )
target_include_directories(linopttest PRIVATE 
    ${EIGEN3_INCLUDE_DIRS}/unsupported
    ${Boost_INCLUDE_DIRS}
    LinConstrOpt/include
)
target_link_libraries(linopttest PRIVATE linconstropt optlib fort GTest::gtest_main GTest::gtest Eigen3::Eigen)
add_pch_to_target(linopttest)


