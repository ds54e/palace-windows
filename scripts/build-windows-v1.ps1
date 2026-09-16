[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
# Invoke through tools/native-dev.cmd after tools/prepare_gate1.py and
# tools/prepare_gate2.py, with the Gate 0 app-local SDK/runtime already staged.
foreach ($component in @('metis','mumps','hypre')) {
    & "$PSScriptRoot/build-no-parmetis-deps.ps1" -Component $component
}
foreach ($script in @('build-mfem','build-libceed','build-core-libs','build-arpack-windows',
                      'test-no-parmetis','test-mfem','build-catch2','build-palace-windows','test-palace-ports','build-sparams')) {
    & "$PSScriptRoot/$script.ps1"
}
$root=Split-Path -Parent $PSScriptRoot
& "$PSScriptRoot/audit-no-parmetis.ps1" -Executable "$root/.work/build/palace-native/palace.exe" -LinkMap "$root/.work/build/palace-native/palace.map"
& "$PSScriptRoot/audit-runtime.ps1" -Executable "$root/.work/build/palace-native/palace.exe"
Write-Output 'Native build and connection workflow completed; release gates remain separate.'
