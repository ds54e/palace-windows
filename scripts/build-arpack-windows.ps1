[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/no-parmetis-arpack"
& cmake.exe -S "$root/.work/sources/arpack-ng" -B $build @common `
    -DMPI=ON -DICB=ON -DINTERFACE64=OFF "-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas" -DBLA_SIZEOF_INTEGER=4
Complete-Build $build
Copy-Item "$root/.work/staging/mpi-probe/msmpi.dll" $build
$env:OMP_NUM_THREADS='1'; $env:MKL_NUM_THREADS='1'
& ctest.exe --test-dir $build --output-on-failure --timeout 60 -E 'issue46|icb_parpack'
if ($LASTEXITCODE -ne 0) { throw 'ARPACK serial tests failed' }
