[CmdletBinding()]
param([switch]$ConfigureOnly)
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/palace-native"
& cmake.exe -S "$root/.work/sources/palace/palace" -B $build @common `
    -DPALACE_WINDOWS_NO_PARMETIS=ON -DPALACE_WITH_MUMPS=ON -DPALACE_WITH_ARPACK=ON `
    -DPALACE_WITH_SUPERLU=OFF -DPALACE_WITH_STRUMPACK=OFF -DPALACE_WITH_SLEPC=OFF `
    -DPALACE_WITH_SUNDIALS=OFF -DPALACE_WITH_GSLIB=OFF -DPALACE_WITH_OPENMP=OFF `
    -DPALACE_WITH_CUDA=OFF -DPALACE_WITH_HIP=OFF -DPALACE_TESTS_NUMPROC=1 `
    "-DMFEM_DIR=$prefix/lib/cmake/mfem" "-DLIBCEED_DIR=$prefix" "-DMUMPS_DIR=$prefix" `
    "-DMETIS_DIR=$prefix" "-DHYPRE_DIR=$prefix" "-DARPACK_DIR=$prefix" `
    "-DCMAKE_MODULE_PATH=$root/cmake" "-DSCALAPACK_LIBRARIES=$scalapack" `
    "-DSCALAPACK_LIBRARY=$cluster/mkl_scalapack_lp64.lib" `
    "-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas" -DBLA_SIZEOF_INTEGER=4 `
    '-DCMAKE_EXE_LINKER_FLAGS=/MAP /VERBOSE:LIB'
if ($LASTEXITCODE -ne 0) { throw 'Native Palace configure failed' }
if (-not $ConfigureOnly) { Complete-Build $build }
