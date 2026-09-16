[CmdletBinding()]
param([switch]$Solvers)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root '.work\build\gate1'
$sdk = Join-Path $root '.work\extracted\sdk'
$mkl = Join-Path $root '.work\deps\mkl'
# The MSI cabinet stores architecture-qualified names; its installed x64 header
# is named mpifptr.h. Preserve bytes while restoring that layout locally.
Copy-Item -LiteralPath (Join-Path $sdk 'mpifptr64.h') -Destination (Join-Path $sdk 'mpifptr.h')
foreach ($tool in @('cmake.exe','ninja.exe','cl.exe','ifx.exe')) {
    Get-Command $tool -CommandType Application -ErrorAction Stop | Out-Null
}
& ifx.exe --version
& cmake.exe -S (Join-Path $root 'tests\abi') -B $build -G Ninja `
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_Fortran_COMPILER=ifx `
    "-DPW_MPI_INCLUDE_DIR=$sdk" "-DPW_MPI_LIBRARY=$sdk\msmpi64.lib" `
    "-DPW_MPI_FORTRAN_LIBRARY=$sdk\msmpifec64.lib" "-DPW_MKL_ROOT=$mkl" "-DPW_WITH_SOLVERS=$($Solvers.IsPresent)"
if ($LASTEXITCODE -ne 0) { throw "Gate 1 configure failed: $LASTEXITCODE" }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw "Gate 1 build failed: $LASTEXITCODE" }
Copy-Item -LiteralPath (Join-Path $root '.work\staging\mpi-probe\msmpi.dll') -Destination $build
& ctest.exe --test-dir $build --output-on-failure
if ($LASTEXITCODE -ne 0) { throw "Gate 1 connection test failed: $LASTEXITCODE" }
Write-Output "Requested connection tests passed on developer host (Solvers=$($Solvers.IsPresent)); deployment evidence remains separate."
