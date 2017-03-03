cmake_minimum_required(VERSION 3.5)
project(CProjects)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES
    CProgLangEx/cpl_1_21.c
    CProgLangEx/fnq.c
    CProgLangEx/foo.c
    CProgLangEx/main.cpp
    firstC/normal/j.h
    firstC/normal/mehra.c
    firstC/normal/mehra.h
    firstC/normal/normal.c
    firstC/normal/normal.h
    firstC/normal/normal_prb.c
    firstC/xcodeC/xcodeC/xcf.c
    firstC/xcodeC/xcodeC/xcf.h
    firstC/blank.c
    firstC/c_header.h
    firstC/functions.c
    firstC/mit.c
    NumericalAnalysis/binomialCoef.c
    NumericalAnalysis/bisectionMethod.c
    NumericalAnalysis/lin_reg.c
    NumericalAnalysis/mmult.c
    NumericalAnalysis/mmult.h
    NumericalAnalysis/normal.c
        NumericalAnalysis/interpolation.cpp
    NumericalAnalysis/truncation_rounding_error.c)

add_executable(CProjects ${SOURCE_FILES})