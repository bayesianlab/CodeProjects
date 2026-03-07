# Install script for directory: /Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/DistLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/CreateSampleDataLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/CrbLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/AskLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/ArkLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/CrtLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/ImpLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/LinRegGibbsLib/cmake_install.cmake")
  include("/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/build/src/ReadCsvLib/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/dillonflannery-valadez/Google Drive/CodeProjects/CProjects/Simulation/src/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
