[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
cmake -S "$root/src/sparams" -B "$root/.work/build/sparams" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=cl
if ($LASTEXITCODE -ne 0) { throw 'S-parameter exporter configure failed' }
cmake --build "$root/.work/build/sparams"
if ($LASTEXITCODE -ne 0) { throw 'S-parameter exporter build failed' }
