
set(EIGEN_INCLUDE_DIR "C:/local/include/eigen-3.4.0")
set(EIGEN_UNSUPPORTED_DIR ${EIGEN_INCLUDE_DIR}/unsupported)
set(GCEM_INCLUDE_DIR "C:/local/include")
set(STATS_INCLUDE_DIR "C:/local/include/stats/include")

# Set include paths for packages
set(BOOST_ROOT "C:/local/newboost/boost_1_89_0")
set(BOOST_INCLUDEDIR ${BOOST_ROOT})
set(BOOST_LIBRARYDIR "${BOOST_ROOT}/stage/lib")

# Header only libraries
if(EXISTS ${EIGEN_INCLUDE_DIR})
    message(STATUS "Eigen3 found")
else()
    message(FATAL_ERROR "Eigen3 NOT FOUND")
endif()
if(EXISTS ${GCEM_INCLUDE_DIR})
    message(STATUS "GCEM found")
else()
    message(FATAL_ERROR "GCEM NOT FOUND")
endif()
if(EXISTS ${STATS_INCLUDE_DIR})
    message(STATUS "Stats found")
else()
    message(FATAL_ERROR "Stats NOT FOUND")
endif()

