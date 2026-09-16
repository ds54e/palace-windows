[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Split-Path -Parent $PSScriptRoot).Replace('\','/')
$sdk = "$root/.work/extracted/sdk"
$mkl = "$root/.work/deps/mkl/build/native"
$env:MKLROOT = $mkl
$blas = "$mkl/win-x64/mkl_intel_lp64.lib;$mkl/win-x64/mkl_sequential.lib;$mkl/win-x64/mkl_core.lib"
$options = @('-G','Ninja','-DCMAKE_BUILD_TYPE=Release','-DCMAKE_C_COMPILER=cl',
    '-DCMAKE_CXX_COMPILER=cl','-DCMAKE_Fortran_COMPILER=ifx',
    '-DPALACE_WINDOWS_NO_PARMETIS=ON',
    "-DPW_WINDOWS_OVERLAY_DIR=$root",'-DCMAKE_C_FLAGS_RELEASE=/O2','-DCMAKE_CXX_FLAGS_RELEASE=/O2',
    "-DCMAKE_INSTALL_PREFIX=$root/.work/install/no-parmetis",'-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL',
    '-DCMAKE_Fortran_FLAGS=/fpscomp:logicals','-DBUILD_SHARED_LIBS=OFF',
    '-DPALACE_WITH_SUPERLU=OFF','-DPALACE_WITH_STRUMPACK=OFF','-DPALACE_WITH_MUMPS=ON',
    '-DPALACE_WITH_SLEPC=OFF','-DPALACE_WITH_ARPACK=ON','-DPALACE_WITH_OPENMP=OFF',
    '-DPALACE_WITH_LIBXSMM=OFF','-DPALACE_WITH_MAGMA=OFF','-DPALACE_WITH_CUDA=OFF',
    '-DPALACE_WITH_HIP=OFF','-DPALACE_WITH_SUNDIALS=OFF',
    '-DPALACE_WITH_64BIT_INT=OFF','-DPALACE_WITH_64BIT_BLAS_INT=OFF',
    '-DPALACE_TESTS_NUMPROC=1','-DPALACE_REGRESSION_NUMPROC=1',
    "-DBLAS_LIBRARIES=$blas","-DLAPACK_LIBRARIES=$blas","-DBLAS_LAPACK_LIBRARIES=$blas",
    "-DBLAS_LAPACK_INCLUDE_DIRS=$mkl/include",'-DBLA_SIZEOF_INTEGER=4',
    '-DMPI_C_LIB_NAMES=msmpi','-DMPI_CXX_LIB_NAMES=msmpi','-DMPI_Fortran_LIB_NAMES=msmpifec;msmpi',
    "-DMPI_msmpi_LIBRARY=$sdk/msmpi64.lib","-DMPI_msmpifec_LIBRARY=$sdk/msmpifec64.lib",
    "-DMPI_C_HEADER_DIR=$sdk","-DMPI_CXX_HEADER_DIR=$sdk","-DMPI_mpifptr_INCLUDE_DIR=$sdk",
    "-DMPI_Fortran_F77_HEADER_DIR=$sdk","-DMPI_Fortran_ADDITIONAL_INCLUDE_DIRS=$sdk",
    '-DEXTERN_METIS_GIT_TAG=08c3082720ff9114b8e3cbaa4484a26739cd7d2d',
    '-DEXTERN_PARMETIS_GIT_TAG=53c9341b6c1ba876c97567cb52ddfc87c159dc36')
& cmake.exe -S "$root/.work/sources/palace" -B "$root/.work/build/palace-no-parmetis" @options
if ($LASTEXITCODE -ne 0) { throw "Palace superbuild configure failed: $LASTEXITCODE" }
Write-Output 'Configure only; this is not a Palace build or a validated distribution.'
