[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
foreach ($case in @('electrostatic','magnetostatic','driven','eigenmode')) {
    & "$PSScriptRoot/run-palace-smoke.ps1" -Case $case *> "$root/.work/gate2/palace-smoke-$case-final.log"
}
Write-Output 'All four native Palace solver processes returned zero; inspect outputs separately.'
