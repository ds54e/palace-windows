cmake_minimum_required(VERSION 3.24)
project(no_parmetis_connection LANGUAGES C CXX Fortran)
if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "Native Windows x64 required")
endif()
get_filename_component(PW_WINDOWS_OVERLAY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
include("${PW_WINDOWS_OVERLAY_DIR}/cmake/WindowsIfxRuntime.cmake")
set(PW_WORK "${PW_WINDOWS_OVERLAY_DIR}/.work")
set(PW_PREFIX "${PW_WORK}/install/no-parmetis")
set(PW_SDK "${PW_WORK}/extracted/sdk")
set(PW_MKL "${PW_WORK}/deps/mkl/build/native/win-x64")
set(PW_CLUSTER "${PW_WORK}/deps/mkl-cluster/build/native/win-x64")
add_executable(mumps-ordering ../abi/mumps_solve.cpp)
target_include_directories(mumps-ordering PRIVATE "${PW_PREFIX}/include" "${PW_SDK}")
target_link_libraries(mumps-ordering PRIVATE
  "${PW_PREFIX}/lib/dmumps.lib" "${PW_PREFIX}/lib/mumps_common.lib" "${PW_PREFIX}/lib/pord.lib"
  "${PW_PREFIX}/lib/metis.lib"
  "${PW_CLUSTER}/mkl_scalapack_lp64.lib" "${PW_CLUSTER}/mkl_blacs_msmpi_lp64.lib"
  "${PW_MKL}/mkl_intel_lp64.lib" "${PW_MKL}/mkl_sequential.lib" "${PW_MKL}/mkl_core.lib"
  "${PW_SDK}/msmpifec64.lib" "${PW_SDK}/msmpi64.lib" ${PW_IFX_RUNTIME_LIBRARIES})
set_target_properties(mumps-ordering PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
target_link_options(mumps-ordering PRIVATE /MAP /VERBOSE:LIB)
enable_testing()
add_test(NAME mumps-pord COMMAND mumps-ordering PORD)
add_test(NAME mumps-metis COMMAND mumps-ordering METIS)
add_subdirectory(../ifx-runtime ifx-runtime)
set_tests_properties(mumps-pord mumps-metis PROPERTIES ENVIRONMENT "OMP_NUM_THREADS=1;MKL_NUM_THREADS=1" TIMEOUT 60)

add_executable(parpack-eigen ../abi/parpack_eigen.cpp)
target_compile_features(parpack-eigen PRIVATE cxx_std_17)
target_include_directories(parpack-eigen PRIVATE "${PW_PREFIX}/include/arpack" "${PW_SDK}")
target_link_libraries(parpack-eigen PRIVATE "${PW_PREFIX}/lib/parpack.lib" "${PW_PREFIX}/lib/arpack.lib"
  "${PW_MKL}/mkl_intel_lp64.lib" "${PW_MKL}/mkl_sequential.lib" "${PW_MKL}/mkl_core.lib"
  "${PW_SDK}/msmpifec64.lib" "${PW_SDK}/msmpi64.lib" ${PW_IFX_RUNTIME_LIBRARIES})
set_target_properties(parpack-eigen PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
add_test(NAME parpack-eigen COMMAND parpack-eigen)
set_tests_properties(parpack-eigen PROPERTIES ENVIRONMENT "OMP_NUM_THREADS=1;MKL_NUM_THREADS=1" TIMEOUT 60)
