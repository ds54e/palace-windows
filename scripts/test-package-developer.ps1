[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$unicode=([char]0x65e5).ToString()+[char]0x672c+[char]0x8a9e
& "$PSScriptRoot/test-staged-package.ps1" -PackageDirectory "$root/.work/package/palace-windows-1.0.0" -OutputRoot "$root/.work/gate4/Staged tests $unicode"
