[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$OutputRoot,
      [switch]$AttestIndependentCleanHost,[switch]$AttestOffline)
$ErrorActionPreference='Stop'
& "$PSScriptRoot/Test-Paths.ps1" -PackageDirectory $PSScriptRoot -OutputRoot $OutputRoot `
    -AttestIndependentCleanHost:$AttestIndependentCleanHost -AttestOffline:$AttestOffline
