cmake_minimum_required(VERSION 3.24)
project(palace_windows_abi LANGUAGES C CXX Fortran)
if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "Native Windows x64 is required")
endif()
set(PW_MPI_INCLUDE_DIR "" CACHE PATH "MS-MPI SDK include directory")
set(PW_MPI_LIBRARY "" CACHE FILEPATH "MS-MPI x64 import library")
set(PW_MPI_FORTRAN_LIBRARY "" CACHE FILEPATH "MS-MPI Intel Fortran x64 binding library")
set(PW_MKL_ROOT "" CACHE PATH "Extracted oneMKL static NuGet package")
foreach(p PW_MPI_INCLUDE_DIR PW_MPI_LIBRARY PW_MPI_FORTRAN_LIBRARY PW_MKL_ROOT)
  if(NOT EXISTS "${${p}}")
    message(FATAL_ERROR "Missing ${p}: ${${p}}")
  endif()
endforeach()
enable_testing()
add_executable(abi-connection connection.cpp c_bridge.c fortran_bridge.f90)
target_compile_features(abi-connection PRIVATE cxx_std_17)
set_property(TARGET abi-connection PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
target_include_directories(abi-connection PRIVATE "${PW_MPI_INCLUDE_DIR}" "${PW_MKL_ROOT}/build/native/include")
target_link_libraries(abi-connection PRIVATE "${PW_MPI_FORTRAN_LIBRARY}" "${PW_MPI_LIBRARY}"
  "${PW_MKL_ROOT}/build/native/win-x64/mkl_intel_lp64.lib"
  "${PW_MKL_ROOT}/build/native/win-x64/mkl_sequential.lib"
  "${PW_MKL_ROOT}/build/native/win-x64/mkl_core.lib")
target_compile_options(abi-connection PRIVATE
  "$<$<COMPILE_LANGUAGE:C,CXX>:/W4;/utf-8>"
  "$<$<COMPILE_LANGUAGE:Fortran>:/warn:all;/check:bounds;/fpscomp:logicals>")
add_test(NAME abi-connection COMMAND abi-connection)
set_tests_properties(abi-connection PROPERTIES TIMEOUT 60 ENVIRONMENT "OMP_NUM_THREADS=1;MKL_NUM_THREADS=1")

option(PW_WITH_SOLVERS "Add tests against prebuilt pinned MUMPS and PARPACK" OFF)
if(PW_WITH_SOLVERS)
  get_filename_component(PW_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
  set(PW_WORK "${PW_ROOT}/.work")
  set(PW_MATH_LIBS
    "${PW_MKL_ROOT}/build/native/win-x64/mkl_intel_lp64.lib"
    "${PW_MKL_ROOT}/build/native/win-x64/mkl_sequential.lib"
    "${PW_MKL_ROOT}/build/native/win-x64/mkl_core.lib")
  add_executable(mumps-solve mumps_solve.cpp)
  target_include_directories(mumps-solve PRIVATE "${PW_WORK}/build/mumps/mumps-src/include" "${PW_MPI_INCLUDE_DIR}")
  target_link_libraries(mumps-solve PRIVATE
    "${PW_WORK}/build/mumps/dmumps.lib" "${PW_WORK}/build/mumps/mumps_common.lib" "${PW_WORK}/build/mumps/pord.lib"
    "${PW_WORK}/deps/mkl-cluster/build/native/win-x64/mkl_scalapack_lp64.lib"
    "${PW_WORK}/deps/mkl-cluster/build/native/win-x64/mkl_blacs_msmpi_lp64.lib"
    ${PW_MATH_LIBS} "${PW_MPI_FORTRAN_LIBRARY}" "${PW_MPI_LIBRARY}")
  add_executable(parpack-eigen parpack_eigen.cpp)
  target_include_directories(parpack-eigen PRIVATE "${PW_WORK}/sources/arpack-ng/ICB" "${PW_WORK}/build/arpack-ng" "${PW_MPI_INCLUDE_DIR}")
  target_link_libraries(parpack-eigen PRIVATE "${PW_WORK}/build/arpack-ng/parpack.lib"
    "${PW_WORK}/build/arpack-ng/arpack.lib" ${PW_MATH_LIBS} "${PW_MPI_FORTRAN_LIBRARY}" "${PW_MPI_LIBRARY}")
  foreach(target mumps-solve parpack-eigen)
    target_compile_features(${target} PRIVATE cxx_std_17)
    set_property(TARGET ${target} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
    add_test(NAME ${target} COMMAND ${target})
    set_tests_properties(${target} PROPERTIES TIMEOUT 60 ENVIRONMENT "OMP_NUM_THREADS=1;MKL_NUM_THREADS=1")
  endforeach()
endif()
