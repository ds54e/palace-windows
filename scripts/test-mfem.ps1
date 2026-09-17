[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/mfem-connection"
& cmake.exe -S "$root/tests/mfem" -B $build @common "-DMFEM_DIR=$prefix/lib/cmake/mfem"
if ($LASTEXITCODE -ne 0) { throw 'MFEM connection configure failed' }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'MFEM connection build failed' }
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" $build
Copy-Item "$prefix/lib/metis.dll" $build -Force
& ctest.exe --test-dir $build --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'MFEM connection failed' }
