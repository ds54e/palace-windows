[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$env:OMP_NUM_THREADS='1'; $env:MKL_NUM_THREADS='1'
$exe="$root/.work/build/palace-native/palace.exe"
foreach ($case in @('electrostatic','magnetostatic','driven','eigenmode')) {
    $directory="$root/.work/gate3/windows/$case"
    Push-Location $directory
    try {
        & $exe config.json > "$directory/run.log"
        if ($LASTEXITCODE -ne 0) { throw "Gate 3 Windows $case failed: $LASTEXITCODE" }
    } finally { Pop-Location }
}
Write-Output 'Four Gate 3 Windows cases completed; equivalence not yet assessed.'
