[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/no-parmetis-tests"
& cmake.exe -S "$root/tests/no-parmetis" -B $build @common
if ($LASTEXITCODE -ne 0) { throw "Connection configure failed" }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw "Connection build failed" }
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" $build
Copy-Item "$prefix/lib/metis.dll" $build -Force
& ctest.exe --test-dir $build --output-on-failure
if ($LASTEXITCODE -ne 0) { throw "Connection tests failed" }
