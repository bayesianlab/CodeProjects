
set(EIGEN_INCLUDE_DIR "/usr/include/eigen3")
set(EIGEN_UNSUPPORTED_DIR ${EIGEN_INCLUDE_DIR}/unsupported)
set(GCEM_INCLUDE_DIR "/usr/include")
set(STATS_INCLUDE_DIR "/usr/include/stats/include")

# Set include paths for packages
set(BOOST_ROOT "/usr")
set(BOOST_INCLUDEDIR ${BOOST_ROOT}/include)
set(BOOST_LIBRARYDIR "${BOOST_ROOT}/lib/x86_64-linux-gnu")

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
    message(STATUS "Stats NOT FOUND - setting fallback path")
    set(STATS_INCLUDE_DIR "/usr/include")
endif()

