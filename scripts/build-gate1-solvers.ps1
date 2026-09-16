[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$cmakeRoot = $root.Replace('\','/')
$sdk = Join-Path $root '.work\extracted\sdk'
$mkl = Join-Path $root '.work\deps\mkl\build\native\win-x64'
$cluster = Join-Path $root '.work\deps\mkl-cluster\build\native\win-x64'
$blas = "$mkl\mkl_intel_lp64.lib;$mkl\mkl_sequential.lib;$mkl\mkl_core.lib"
$scalapack = "$cluster\mkl_scalapack_lp64.lib;$cluster\mkl_blacs_msmpi_lp64.lib"
$common = @('-G','Ninja','-DCMAKE_BUILD_TYPE=Release','-DCMAKE_C_COMPILER=cl',
    '-DCMAKE_CXX_COMPILER=cl','-DCMAKE_Fortran_COMPILER=ifx','-DBUILD_SHARED_LIBS=OFF',
    '-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL','-DCMAKE_Fortran_FLAGS=/fpscomp:logicals',
    "-DBLAS_LIBRARIES=$blas","-DLAPACK_LIBRARIES=$blas",
    '-DBLA_SIZEOF_INTEGER=4','-DMPI_C_LIB_NAMES=msmpi','-DMPI_CXX_LIB_NAMES=msmpi','-DMPI_Fortran_LIB_NAMES=msmpifec;msmpi',
    "-DMPI_msmpi_LIBRARY=$sdk\msmpi64.lib","-DMPI_msmpifec_LIBRARY=$sdk\msmpifec64.lib",
    "-DMPI_C_HEADER_DIR=$sdk","-DMPI_CXX_HEADER_DIR=$sdk","-DMPI_mpifptr_INCLUDE_DIR=$sdk","-DMPI_Fortran_F77_HEADER_DIR=$sdk",
    "-DMPI_Fortran_ADDITIONAL_INCLUDE_DIRS=$sdk")
Copy-Item -LiteralPath "$sdk\mpifptr64.h" -Destination "$sdk\mpifptr.h"
foreach ($name in @('arpack-ng','mumps')) {
    $source = Join-Path $root ".work\sources\$name"
    $build = Join-Path $root ".work\build\$name"
    $options = @()
    if ($name -eq 'arpack-ng') {
        $options = @('-DMPI=ON','-DICB=ON','-DINTERFACE64=OFF')
    } else {
        # PORD is sufficient for the first connection solve. METIS/ParMETIS
        # integration remains required by the selected Palace superbuild recipe.
        $options = @('-DMUMPS_parallel=ON','-DMUMPS_scalapack=ON','-DMUMPS_openmp=OFF',
            '-Dintsize64=OFF','-DBUILD_SINGLE=OFF','-DBUILD_DOUBLE=ON',
            '-DBUILD_COMPLEX=OFF','-DBUILD_COMPLEX16=OFF','-DMUMPS_BUILD_TESTING=OFF',
            "-DSCALAPACK_LIBRARIES=$scalapack", "-DCMAKE_MODULE_PATH=$cmakeRoot/cmake",
            "-DPW_MUMPS_ARCHIVE=$root\.work\downloads\MUMPS_5.7.3.tar.gz")
    }
    # CMake forwards library lists into generated try_compile scripts. Use
    # forward slashes there so Windows paths are not parsed as CMake escapes.
    $common = @($common | ForEach-Object { $_.Replace('\','/') })
    $options = @($options | ForEach-Object { $_.Replace('\','/') })
    & cmake.exe -S $source -B $build @common @options
    if ($LASTEXITCODE -ne 0) { throw "$name configure failed: $LASTEXITCODE" }
    & cmake.exe --build $build --parallel 2
    if ($LASTEXITCODE -ne 0) { throw "$name build failed: $LASTEXITCODE" }
}
