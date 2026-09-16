[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/build-no-parmetis-deps.ps1" -Component metis
& "$PSScriptRoot/build-arpack-windows.ps1"
& "$PSScriptRoot/test-no-parmetis.ps1"
& "$PSScriptRoot/test-mfem.ps1"
