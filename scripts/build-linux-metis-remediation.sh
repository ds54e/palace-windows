#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
root="$reference_root"
base="$root/.work/legal-remediation"
candidate="$base/linux-prefix"
metis_build="$base/linux-build/metis"
palace_build="$base/linux-build/palace"
reference="$reference_prefix"
blas="$reference_sysroot/usr/lib64/libopenblas.so.0"

cmake -S "$root/.work/sources/metis" -B "$metis_build" -G 'Unix Makefiles' \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
  -DCMAKE_C_FLAGS_RELEASE=-O2 -DCMAKE_CXX_FLAGS_RELEASE=-O2 \
  -DCMAKE_INSTALL_PREFIX="$candidate" -DCMAKE_INSTALL_LIBDIR=lib \
  -DGKLIB_PATH="$root/.work/sources/metis/GKlib" \
  -DMETIS_USE_LONGINDEX=OFF -DMETIS_USE_DOUBLEPRECISION=OFF \
  -DSHARED=OFF -DASSERT=ON -DASSERT2=ON
cmake --build "$metis_build" --parallel 4
cmake --install "$metis_build"

cmake -S "$root/.work/linux-reference/sources/palace/palace" -B "$palace_build" \
  -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
  -DCMAKE_Fortran_COMPILER="$OMPI_FC" \
  -DCMAKE_C_FLAGS_RELEASE=-O2 -DCMAKE_CXX_FLAGS_RELEASE=-O2 \
  -DCMAKE_Fortran_FLAGS_RELEASE=-O2 -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX="$base/linux-install" \
  -DCMAKE_PREFIX_PATH="$candidate;$reference" -DCMAKE_INSTALL_LIBDIR=lib \
  -DBLA_SIZEOF_INTEGER=4 -DBLAS_LIBRARIES="$blas" -DLAPACK_LIBRARIES="$blas" \
  -DPALACE_WINDOWS_NO_PARMETIS=ON -DPALACE_WITH_MUMPS=ON \
  -DPALACE_WITH_ARPACK=ON -DPALACE_WITH_SUPERLU=OFF \
  -DPALACE_WITH_STRUMPACK=OFF -DPALACE_WITH_SLEPC=OFF \
  -DPALACE_WITH_SUNDIALS=OFF -DPALACE_WITH_GSLIB=OFF \
  -DPALACE_WITH_OPENMP=OFF -DPALACE_WITH_CUDA=OFF -DPALACE_WITH_HIP=OFF \
  -DPALACE_TESTS_NUMPROC=1 -DMFEM_DIR="$reference/lib/cmake/mfem" \
  -DLIBCEED_DIR="$reference" -DMUMPS_DIR="$reference" \
  -DMETIS_DIR="$candidate" -DHYPRE_DIR="$reference" -DARPACK_DIR="$reference" \
  -DCMAKE_MODULE_PATH="$root/cmake" \
  -DSCALAPACK_LIBRARIES="$reference/lib/libscalapack.a" \
  -DCMAKE_EXE_LINKER_FLAGS=-Wl,-Map,palace.map
cmake --build "$palace_build" --parallel 4

echo "Linux remediated METIS and Palace candidate built under $base"
