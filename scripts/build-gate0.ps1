[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$MpiIncludeDir,
    [Parameter(Mandatory=$true)][string]$MpiLibrary,
    [string]$BuildDir,
    [string]$Generator
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Native Windows build required.' }
$root = Split-Path -Parent $PSScriptRoot
if (-not $BuildDir) { $BuildDir = Join-Path $root '.work\build\gate0' }
$cmake = Get-Command cmake.exe -CommandType Application -ErrorAction Stop
$include = (Resolve-Path -LiteralPath $MpiIncludeDir).Path
$lib = (Resolve-Path -LiteralPath $MpiLibrary).Path
if (-not (Test-Path -LiteralPath (Join-Path $include 'mpi.h'))) { throw 'mpi.h is missing.' }
$argsList = @('-S',(Join-Path $root 'tests\runtime'),'-B',$BuildDir,
    "-DPW_MPI_INCLUDE_DIR=$include","-DPW_MPI_LIBRARY=$lib",'-DCMAKE_BUILD_TYPE=Release')
if ($Generator) { $argsList += @('-G',$Generator) }
& $cmake.Source @argsList
if ($LASTEXITCODE -ne 0) { throw "CMake configure failed: $LASTEXITCODE" }
& $cmake.Source --build $BuildDir --config Release --parallel 2
if ($LASTEXITCODE -ne 0) { throw "Probe build failed: $LASTEXITCODE" }
Write-Output 'Probe built. This is not a runtime/clean-host pass. Stage only provenance-reviewed runtime files before testing.'
