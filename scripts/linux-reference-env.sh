#!/usr/bin/env bash
# Source in a repository-local reference build/run shell; never a system profile.
reference_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
reference_sysroot="$reference_root/.work/linux-reference/sysroot"
reference_prefix="$reference_root/.work/linux-reference/install"
export LD_LIBRARY_PATH="$reference_prefix/lib:$reference_prefix/lib64:$reference_sysroot/usr/lib64:$reference_sysroot/usr/lib64/openmpi/lib"
export OPAL_PREFIX="$reference_sysroot/usr/lib64/openmpi"
export OPAL_DATADIR="$OPAL_PREFIX/share"
export OPAL_INCLUDEDIR="$reference_sysroot/usr/include/openmpi-x86_64"
export OPAL_LIBDIR="$OPAL_PREFIX/lib"
export PMIX_INSTALL_PREFIX="$reference_sysroot/usr"
export PMIX_LIBDIR="$reference_sysroot/usr/lib64"
export PMIX_PKGLIBDIR="$reference_sysroot/usr/lib64/pmix"
export PMIX_PKGDATADIR="$reference_sysroot/usr/share/pmix"
export PATH="$reference_root/.work/linux-reference/bin:$OPAL_PREFIX/bin:$PATH"
export OMPI_FC="$reference_root/.work/linux-reference/bin/gfortran-reference"
export PKG_CONFIG_PATH="$reference_prefix/lib/pkgconfig:$reference_prefix/lib64/pkgconfig"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
