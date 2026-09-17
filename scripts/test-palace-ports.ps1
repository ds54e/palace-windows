[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build="$root/.work/build/palace-native"
& cmake.exe -S "$root/.work/sources/palace/palace" -B $build -DPW_WINDOWS_PORT_TESTS=ON
if ($LASTEXITCODE -ne 0) { throw 'Port-test configure failed' }
& cmake.exe --build $build --target windows-port-tests --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'Port-test build failed' }
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" "$build/windows-port-tests" -Force
Copy-Item "$prefix/lib/metis.dll" "$build/windows-port-tests" -Force
Push-Location "$build/windows-port-tests"
try {
    & './windows-port-tests.exe' '[Serial]' --reporter console
    if ($LASTEXITCODE -ne 0) { throw "Port tests failed: $LASTEXITCODE" }
} finally { Pop-Location }
