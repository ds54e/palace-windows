[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root '.work\build\arpack-ng'
$env:OMP_NUM_THREADS = '1'
$env:MKL_NUM_THREADS = '1'
# Three upstream tests require a two-rank mpiexec launcher; they remain unrun.
# The separate Gate 1 PARPACK tests validate the required singleton contract.
& ctest.exe --test-dir $build --output-on-failure --timeout 60 -E 'issue46|icb_parpack'
if ($LASTEXITCODE -ne 0) { throw "ARPACK serial test failure: $LASTEXITCODE" }
