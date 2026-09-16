[CmdletBinding()]
param([ValidateSet('electrostatic','magnetostatic','driven','eigenmode')][string]$Case)
. "$PSScriptRoot/gate2-common.ps1"
$exe = "$root/.work/build/palace-native/palace.exe"
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" (Split-Path -Parent $exe)
$env:OMP_NUM_THREADS='1'; $env:MKL_NUM_THREADS='1'
Push-Location "$root/.work/gate2/palace-smoke/$Case"
try {
    & $exe config.json
    if ($LASTEXITCODE -ne 0) { throw "Palace $Case failed: $LASTEXITCODE" }
} finally { Pop-Location }
