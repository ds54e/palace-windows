#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
build="$reference_root/.work/linux-reference/build/connections"
mkdir -p "$build"
cmake -S "$reference_root/tests/mfem" -B "$build/mfem" \
  -DCMAKE_BUILD_TYPE=Release '-DCMAKE_CXX_FLAGS_RELEASE=-O2' \
  "-DCMAKE_PREFIX_PATH=$reference_prefix"
cmake --build "$build/mfem" --parallel 2
(cd "$build/mfem" && ctest --output-on-failure)
mpicxx -std=c++17 -O2 -I"$reference_prefix/include/arpack" \
  "$reference_root/tests/abi/parpack_eigen.cpp" -L"$reference_prefix/lib" \
  -lparpack -larpack -L"$OPAL_LIBDIR" -lmpi_mpifh \
  "$reference_sysroot/usr/lib64/libopenblas.so.0" \
  "$reference_sysroot/usr/lib64/libgfortran.so.5" \
  "$reference_sysroot/usr/lib64/libquadmath.so.0" -o "$build/parpack-eigen"
"$build/parpack-eigen"
