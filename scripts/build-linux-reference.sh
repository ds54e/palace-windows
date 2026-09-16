#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
root="$reference_root"
prefix="$reference_prefix"
base="$root/.work/linux-reference"
blas="$reference_sysroot/usr/lib64/libopenblas.so.0"
common=(-G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++
 "-DCMAKE_Fortran_COMPILER=$OMPI_FC" '-DCMAKE_C_FLAGS_RELEASE=-O2' '-DCMAKE_CXX_FLAGS_RELEASE=-O2'
 '-DCMAKE_Fortran_FLAGS_RELEASE=-O2' -DBUILD_SHARED_LIBS=OFF "-DCMAKE_INSTALL_PREFIX=$prefix"
 "-DCMAKE_PREFIX_PATH=$prefix" '-DCMAKE_INSTALL_LIBDIR=lib' -DBLA_SIZEOF_INTEGER=4)
math=("-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas")
component=${1:?Specify metis, scalapack, mumps, hypre, mfem, arpack, ceed, core or palace}
build="$base/build/$component"
mkdir -p "$build"
case "$component" in
 metis)
  cmake -S "$root/.work/sources/metis" -B "$build" "${common[@]}" "-DGKLIB_PATH=$root/.work/sources/metis/GKlib" -DMETIS_USE_LONGINDEX=OFF -DMETIS_USE_DOUBLEPRECISION=OFF -DSHARED=OFF -DASSERT=ON -DASSERT2=ON ;;
 scalapack)
  cmake -S "$base/sources/scalapack" -B "$build" "${common[@]}" "${math[@]}" -DSCALAPACK_BUILD_TESTS=OFF ;;
 mumps)
  cmake -S "$root/.work/sources/mumps" -B "$build" "${common[@]}" "${math[@]}" -DMUMPS_parallel=ON -DMUMPS_scalapack=ON -DMUMPS_openmp=OFF -Dintsize64=OFF -DBUILD_SINGLE=OFF -DBUILD_DOUBLE=ON -DBUILD_COMPLEX=OFF -DBUILD_COMPLEX16=OFF -DMUMPS_BUILD_TESTING=OFF -Dmetis=ON -Dparmetis=OFF -Dscotch=OFF "-DMETIS_LIBRARY=$prefix/lib/libmetis.a" "-DMETIS_INCLUDE_DIR=$prefix/include" '-DPARMETIS_LIBRARY=' "-DSCALAPACK_LIBRARIES=$prefix/lib/libscalapack.a" "-DCMAKE_MODULE_PATH=$root/cmake" "-DPW_MUMPS_ARCHIVE=$root/.work/downloads/MUMPS_5.7.3.tar.gz" ;;
 hypre)
  cmake -S "$root/.work/sources/hypre/src" -B "$build" "${common[@]}" -DHYPRE_ENABLE_MPI=ON -DHYPRE_ENABLE_FORTRAN=OFF -DHYPRE_ENABLE_OPENMP=OFF -DHYPRE_ENABLE_MIXEDINT=OFF -DHYPRE_ENABLE_BIGINT=OFF -DHYPRE_ENABLE_HYPRE_BLAS=OFF -DHYPRE_ENABLE_HYPRE_LAPACK=OFF "-DTPL_BLAS_LIBRARIES=$blas" "-DTPL_LAPACK_LIBRARIES=$blas" ;;
 mfem)
  cmake -S "$root/.work/sources/mfem" -B "$build" "${common[@]}" "${math[@]}" '-DCMAKE_CXX_FLAGS=-DPW_MUMPS_NO_PARMETIS' -DMFEM_DEBUG=ON -DMFEM_USE_MPI=ON -DMFEM_USE_METIS=ON -DMFEM_USE_METIS_5=ON -DMFEM_USE_MUMPS=ON -DMFEM_USE_LAPACK=ON -DMFEM_USE_OPENMP=OFF -DMFEM_USE_CEED=OFF -DMFEM_USE_GSLIB=OFF -DMFEM_USE_SUPERLU=OFF -DMFEM_USE_STRUMPACK=OFF -DMFEM_USE_SUNDIALS=OFF -DMFEM_USE_ZLIB=OFF -DMFEM_USE_EXCEPTIONS=ON -DMFEM_ENABLE_EXAMPLES=OFF -DMFEM_ENABLE_MINIAPPS=OFF "-DHYPRE_DIR=$prefix" '-DHYPRE_REQUIRED_PACKAGES=MPI;BLAS;LAPACK' "-DMETIS_DIR=$prefix" "-DMUMPS_DIR=$prefix" '-DMUMPS_REQUIRED_PACKAGES=METIS;LAPACK;BLAS;MPI;MPI_Fortran;Threads' "-DMUMPS_REQUIRED_LIBRARIES=$prefix/lib/libscalapack.a;$reference_sysroot/usr/lib64/libgfortran.so.5;$reference_sysroot/usr/lib64/libquadmath.so.0" ;;
 arpack)
  cmake -S "$base/sources/arpack-ng" -B "$build" "${common[@]}" "${math[@]}" -DMPI=ON -DICB=ON -DINTERFACE64=OFF -DTESTS=OFF ;;
 ceed)
  make -C "$base/sources/libCEED" -j2 prefix="$prefix" CC=gcc CXX=g++ FC= 'OPT=-O2' STATIC=1 CUDA_DIR= ROCM_DIR= XSMM_DIR= MAGMA_DIR= install
  exit ;;
 core)
  for name in json json-schema-validator fmt scn eigen; do
   options=()
   case "$name" in
    json) options=(-DJSON_Install=ON -DJSON_BuildTests=OFF) ;;
    json-schema-validator) options=(-DJSON_VALIDATOR_INSTALL=ON -DJSON_VALIDATOR_BUILD_TESTS=OFF -DJSON_VALIDATOR_BUILD_EXAMPLES=OFF -DJSON_VALIDATOR_SHARED_LIBS=OFF) ;;
    fmt) options=(-DFMT_INSTALL=ON -DFMT_DOC=OFF -DFMT_TEST=OFF) ;;
    scn) options=(-DSCN_INSTALL=ON -DSCN_REGEX_BACKEND=std -DSCN_DISABLE_TOP_PROJECT=ON) ;;
    eigen) options=(-DEIGEN_BUILD_DOC=OFF -DBUILD_TESTING=OFF -DEIGEN_BUILD_TESTING=OFF -DEIGEN_BUILD_BLAS=OFF -DEIGEN_BUILD_LAPACK=OFF -DEIGEN_BUILD_DEMOS=OFF) ;;
   esac
   cmake -S "$root/.work/sources/$name" -B "$base/build/$name" "${common[@]}" "${options[@]}"
   cmake --build "$base/build/$name" --parallel 2
   cmake --install "$base/build/$name"
  done
  exit ;;
 palace)
  cmake -S "$base/sources/palace/palace" -B "$build" "${common[@]}" "${math[@]}" -DPALACE_WINDOWS_NO_PARMETIS=ON -DPALACE_WITH_MUMPS=ON -DPALACE_WITH_ARPACK=ON -DPALACE_WITH_SUPERLU=OFF -DPALACE_WITH_STRUMPACK=OFF -DPALACE_WITH_SLEPC=OFF -DPALACE_WITH_SUNDIALS=OFF -DPALACE_WITH_GSLIB=OFF -DPALACE_WITH_OPENMP=OFF -DPALACE_WITH_CUDA=OFF -DPALACE_WITH_HIP=OFF -DPALACE_TESTS_NUMPROC=1 "-DMFEM_DIR=$prefix/lib/cmake/mfem" "-DLIBCEED_DIR=$prefix" "-DMUMPS_DIR=$prefix" "-DMETIS_DIR=$prefix" "-DHYPRE_DIR=$prefix" "-DARPACK_DIR=$prefix" "-DCMAKE_MODULE_PATH=$root/cmake" "-DSCALAPACK_LIBRARIES=$prefix/lib/libscalapack.a" '-DCMAKE_EXE_LINKER_FLAGS=-Wl,-Map,palace.map' ;;
 *) exit 2 ;;
esac
cmake --build "$build" --parallel 2
cmake --install "$build"
