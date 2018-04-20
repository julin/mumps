# - Try to find MUMPS
# https://cmake.org/cmake/help/v3.11/manual/cmake-developer.7.html#find-modules

#.rst:
# FindMUMPS
# -------
#
# Finds the MUMPS library
#
# This will define the following variables::
#
#   MUMPS_FOUND    - True if the system has the MUMPS library
#   MUMPS_VERSION  - The version of the MUMPS library which was found

find_package(LAPACK)
if (NOT LAPACK_FOUND)
  return()
endif()
# ----- MPI
find_package(MPI COMPONENTS Fortran)
if (NOT MPI_FOUND)
  return()
endif()

find_package(Threads REQUIRED)
add_compile_options(${MPI_Fortran_COMPILE_OPTIONS})
include_directories(${MPI_Fortran_INCLUDE_DIRS})

#-------------------------

find_package(PkgConfig)
pkg_check_modules(PC_MUMPS QUIET MUMPS)


find_path(MUMPS_INCLUDE_DIR
          NAMES mumps_compat.h
          PATHS ${PC_MUMPS_INCLUDE_DIRS}
          PATH_SUFFIXES MUMPS include
          HINTS ${MUMPS_ROOT})

find_library(MUMPS_COMMON
             NAMES mumps_common
             PATHS ${PC_MUMPS_LIBRARY_DIRS}
             PATH_SUFFIXES MUMPS lib
             HINTS ${MUMPS_ROOT})
             
get_filename_component(MUMPS_DIR ${MUMPS_COMMON} DIRECTORY)
find_library(DMUMPS NAMES dmumps HINTS ${MUMPS_DIR})
find_library(SMUMPS NAMES smumps HINTS ${MUMPS_DIR})
find_library(CMUMPS NAMES cmumps HINTS ${MUMPS_DIR})
find_library(ZMUMPS NAMES zmumps HINTS ${MUMPS_DIR})
find_library(PORD NAMES pord HINTS ${MUMPS_DIR})

set(MUMPS_VERSION ${PC_MUMPS_VERSION})


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS
    FOUND_VAR MUMPS_FOUND
    REQUIRED_VARS MUMPS_COMMON MUMPS_INCLUDE_DIR
    VERSION_VAR MUMPS_VERSION)

if(MUMPS_FOUND)
  set(MUMPS_LIBRARIES ${MUMPS_COMMON} ${DMUMPS} ${SMUMPS} ${CMUMPS} ${ZMUMPS} ${PORD} ${LAPACK_LIBRARIES} ${MPI_Fortran_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT}) 
  set(MUMPS_INCLUDE_DIRS ${MUMPS_INCLUDE_DIR} ${LAPACK_INCLUDE_DIRS})
  set(MUMPS_DEFINITIONS  ${PC_MUMPS_CFLAGS_OTHER})
endif()


mark_as_advanced(MUMPS_INCLUDE_DIR MUMPS_LIBRARY)

