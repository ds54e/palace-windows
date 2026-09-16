#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
build="$reference_root/.work/linux-reference/build/connections"
mkdir -p "$build"
mpicxx -std=c++17 -O2 -I"$reference_prefix/include" "$reference_root/tests/abi/mumps_solve.cpp" \
 -L"$reference_prefix/lib" -ldmumps -lmumps_common -lpord -lmetis -lscalapack \
 -L"$OPAL_LIBDIR" -lmpi_mpifh "$reference_sysroot/usr/lib64/libopenblas.so.0" \
 "$reference_sysroot/usr/lib64/libgfortran.so.5" "$reference_sysroot/usr/lib64/libquadmath.so.0" \
 -o "$build/mumps-ordering"
"$build/mumps-ordering" PORD
"$build/mumps-ordering" METIS
