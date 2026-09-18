[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$candidate = "$root/.work/install/metis-remediation"
$build = "$root/.work/build/metis-remediation-connections"
& cmake.exe -S "$root/tests/no-parmetis" -B $build @common `
    "-DPW_METIS_PREFIX=$candidate"
if ($LASTEXITCODE -ne 0) { throw 'Remediation connection configure failed' }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'Remediation connection build failed' }
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" $build -Force
Copy-Item "$candidate/lib/metis.dll" $build -Force
& ctest.exe --test-dir $build --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Remediation connection tests failed' }
Write-Output 'PORD, METIS, PARPACK and mixed-runtime remediation connections passed.'
