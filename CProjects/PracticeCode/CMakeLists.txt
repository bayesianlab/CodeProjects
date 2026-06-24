project(practice)

if(NOT MSVC)
  add_executable(diamond Interviews/diamond.cpp)

  add_executable(const Interviews/const.cpp)
else()
  message(STATUS "Skipping PracticeCode targets on MSVC because sources use GCC-specific headers")
endif()