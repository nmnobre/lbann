include(ExternalProject)

# Library type (defaults to shared library)
if(NOT ELEMENTAL_LIBRARY_TYPE)
  set(ELEMENTAL_LIBRARY_TYPE SHARED)
endif()

# Try finding Elemental
if(NOT FORCE_ELEMENTAL_BUILD)
  find_package(Elemental QUIET HINTS ${Elemental_DIR})
endif()

# Check if Elemental has been found
if(Elemental_FOUND AND NOT FORCE_ELEMENTAL_BUILD)

  # Status message
  message(STATUS "Found Elemental (version ${Elemental_VERSION}): ${Elemental_DIR}")

else()

  # Git repository URL and tag
  if(NOT ELEMENTAL_URL)
    set(ELEMENTAL_URL "https://github.com/elemental/Elemental.git")
  endif()
  if(NOT ELEMENTAL_TAG)
     # Commit from 5/30/2016
     set(ELEMENTAL_TAG "4a33924fe57aacbe84a3bcf089dcffe034cb979e")
  endif()
  message(STATUS "Will pull Elemental (tag ${ELEMENTAL_TAG}) from ${ELEMENTAL_URL}")

  # Elemental build options
  if(NOT ELEMENTAL_BUILD_TYPE)
    set(ELEMENTAL_BUILD_TYPE ${CMAKE_BUILD_TYPE})
  endif()
  option(ELEMENTAL_HYBRID "Elemental: make use of OpenMP within MPI packing/unpacking" OFF)
  option(ELEMENTAL_C_INTERFACE "Elemental: build C interface?" OFF)
  option(ELEMENTAL_INSTALL_PYTHON_PACKAGE "Elemental: install Python interface?" OFF)
  option(ELEMENTAL_DISABLE_PARMETIS "Elemental: disable ParMETIS?" ON)

  # Determine library type
  if(${ELEMENTAL_LIBRARY_TYPE} STREQUAL STATIC)
    set(ELEMENTAL_BUILD_SHARED_LIBS OFF)
  elseif(${ELEMENTAL_LIBRARY_TYPE} STREQUAL SHARED)
    set(ELEMENTAL_BUILD_SHARED_LIBS ON)
  else()
    message(WARNING "Elemental: unknown library type (${ELEMENTAL_LIBRARY_TYPE}), defaulting to shared library.")
    set(ELEMENTAL_BUILD_SHARED_LIBS ON)
  endif()

  # Download and build location
  set(ELEMENTAL_SOURCE_DIR "${PROJECT_BINARY_DIR}/download/elemental/source")
  set(ELEMENTAL_BINARY_DIR "${PROJECT_BINARY_DIR}/download/elemental/build")

  # Get Elemental from Git repository and build
  ExternalProject_Add(project_Elemental
    PREFIX          ${CMAKE_INSTALL_PREFIX}
    TMP_DIR         "${ELEMENTAL_BINARY_DIR}/tmp"
    STAMP_DIR       "${ELEMENTAL_BINARY_DIR}/stamp"
    GIT_REPOSITORY  ${ELEMENTAL_URL}
    GIT_TAG         ${ELEMENTAL_TAG}
    SOURCE_DIR      ${ELEMENTAL_SOURCE_DIR}
    BINARY_DIR      ${ELEMENTAL_BINARY_DIR}
    BUILD_COMMAND   ${CMAKE_MAKE_PROGRAM} -j${MAKE_NUM_PROCESSES}
    INSTALL_DIR     ${CMAKE_INSTALL_PREFIX}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install -j${MAKE_NUM_PROCESSES}
    CMAKE_ARGS
      -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -D CMAKE_BUILD_TYPE=${ELEMENTAL_BUILD_TYPE}
      -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -D CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
      -D MPI_C_COMPILER=${MPI_C_COMPILER}
      -D MPI_CXX_COMPILER=${MPI_CXX_COMPILER}
      -D MPI_Fortran_COMPILER=${MPI_Fortran_COMPILER}
      -D MATH_LIBS=${MATH_LIBS}
      -D BUILD_SHARED_LIBS=${ELEMENTAL_BUILD_SHARED_LIBS}
      -D EL_HYBRID=${ELEMENTAL_HYBRID}
      -D EL_C_INTERFACE=${ELEMENTAL_C_INTERFACE}
      -D INSTALL_PYTHON_PACKAGE=${ELEMENTAL_INSTALL_PYTHON_PACKAGE}
      -D EL_DISABLE_PARMETIS=${ELEMENTAL_DISABLE_PARMETIS}
  )

  # Get install directory
  set(Elemental_DIR "${CMAKE_INSTALL_PREFIX}")

  # Get header files
  set(Elemental_INCLUDE_DIRS "${Elemental_DIR}/include")

  # Get library
  if(ELEMENTAL_SHARED_LIBS STREQUAL STATIC)
    set(Elemental_LIBRARIES "${Elemental_DIR}/lib/libEl.a")
  else()
    set(Elemental_LIBRARIES "${Elemental_DIR}/lib/libEl.so")
  endif()

  # LBANN has built Elemental
  set(LBANN_BUILT_ELEMENTAL TRUE)

endif()

# Include header files
include_directories(${Elemental_INCLUDE_DIRS})

# Add preprocessor flag for Elemental
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__LIB_ELEMENTAL")

# LBANN has access to Elemental
set(LBANN_HAS_ELEMENTAL TRUE)
