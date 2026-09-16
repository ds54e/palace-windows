$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Split-Path -Parent $PSScriptRoot).Replace('\','/')
$sdk = "$root/.work/extracted/sdk"
$prefix = "$root/.work/install/no-parmetis"
$mkl = "$root/.work/deps/mkl/build/native"
$cluster = "$root/.work/deps/mkl-cluster/build/native/win-x64"
$blas = "$mkl/win-x64/mkl_intel_lp64.lib;$mkl/win-x64/mkl_sequential.lib;$mkl/win-x64/mkl_core.lib"
$scalapack = "$cluster/mkl_scalapack_lp64.lib;$cluster/mkl_blacs_msmpi_lp64.lib"
$mpi = @('-DMPI_C_LIB_NAMES=msmpi','-DMPI_CXX_LIB_NAMES=msmpi','-DMPI_Fortran_LIB_NAMES=msmpifec;msmpi',
    "-DMPI_msmpi_LIBRARY=$sdk/msmpi64.lib","-DMPI_msmpifec_LIBRARY=$sdk/msmpifec64.lib",
    "-DMPI_C_HEADER_DIR=$sdk","-DMPI_CXX_HEADER_DIR=$sdk",
    "-DMPI_C_ADDITIONAL_INCLUDE_DIRS=$sdk","-DMPI_CXX_ADDITIONAL_INCLUDE_DIRS=$sdk","-DMPI_mpifptr_INCLUDE_DIR=$sdk",
    "-DMPI_Fortran_F77_HEADER_DIR=$sdk","-DMPI_Fortran_ADDITIONAL_INCLUDE_DIRS=$sdk")
$common = @('-G','Ninja','-DCMAKE_BUILD_TYPE=Release','-DCMAKE_C_COMPILER=cl','-DCMAKE_CXX_COMPILER=cl',
    '-DCMAKE_Fortran_COMPILER=ifx','-DCMAKE_CXX_FLAGS=/EHsc /utf-8','-DCMAKE_C_FLAGS_RELEASE=/O2','-DCMAKE_CXX_FLAGS_RELEASE=/O2',
    '-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL','-DCMAKE_Fortran_FLAGS=/fpscomp:logicals',
    '-DBUILD_SHARED_LIBS=OFF',"-DCMAKE_INSTALL_PREFIX=$prefix","-DCMAKE_PREFIX_PATH=$prefix") + $mpi
function Complete-Build([string]$build) {
    if ($LASTEXITCODE -ne 0) { throw "Configure failed: $build ($LASTEXITCODE)" }
    & cmake.exe --build $build --parallel 2
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $build ($LASTEXITCODE)" }
    & cmake.exe --install $build
    if ($LASTEXITCODE -ne 0) { throw "Install failed: $build ($LASTEXITCODE)" }
}
