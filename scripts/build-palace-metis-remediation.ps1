[CmdletBinding()]
param()

. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/palace-metis-remediation"
$metis = "$root/.work/install/metis-remediation"
$install = "$root/.work/install/palace-metis-remediation"

& cmake.exe -S "$root/.work/sources/palace/palace" -B $build @common `
    "-DCMAKE_INSTALL_PREFIX=$install" `
    "-DPW_WINDOWS_OVERLAY_DIR=$root" '-DCMAKE_CXX_FLAGS=/EHsc /utf-8 /Zc:lambda' `
    -DPALACE_WINDOWS_NO_PARMETIS=ON -DPALACE_WITH_MUMPS=ON -DPALACE_WITH_ARPACK=ON `
    -DPALACE_WITH_SUPERLU=OFF -DPALACE_WITH_STRUMPACK=OFF -DPALACE_WITH_SLEPC=OFF `
    -DPALACE_WITH_SUNDIALS=OFF -DPALACE_WITH_GSLIB=OFF -DPALACE_WITH_OPENMP=OFF `
    -DPALACE_WITH_CUDA=OFF -DPALACE_WITH_HIP=OFF -DPALACE_TESTS_NUMPROC=1 `
    "-DMFEM_DIR=$prefix/lib/cmake/mfem" "-DLIBCEED_DIR=$prefix" "-DMUMPS_DIR=$prefix" `
    "-DMETIS_DIR=$metis" "-DMETIS_LIBRARY=$metis/lib/metis.lib" "-DMETIS_INCLUDE_DIR=$metis/include" `
    "-DHYPRE_DIR=$prefix" "-DARPACK_DIR=$prefix" "-DCMAKE_MODULE_PATH=$root/cmake" `
    "-DSCALAPACK_LIBRARIES=$scalapack" "-DSCALAPACK_LIBRARY=$cluster/mkl_scalapack_lp64.lib" `
    "-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas" -DBLA_SIZEOF_INTEGER=4 `
    "-DCMAKE_EXE_LINKER_FLAGS=/MAP /VERBOSE:LIB /NODEFAULTLIB:libircmt.lib `"$root/.work/deps/intel/Library/lib/libircmd.lib`" `"$root/.work/deps/intel/Library/lib/libircdisp.lib`""
if ($LASTEXITCODE -ne 0) { throw 'Remediated Palace configure failed' }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'Remediated Palace build failed' }
Copy-Item "$metis/lib/metis.dll" "$build/metis.dll" -Force

$cache = Get-Content -LiteralPath "$build/CMakeCache.txt" -Raw
if ($cache -notmatch [regex]::Escape("METIS_LIBRARY:FILEPATH=$metis/lib/metis.lib")) { throw 'Candidate METIS import library was not selected' }
$map = Get-Content -LiteralPath "$build/palace.map" -Raw
if ($map -match '(?i)libircmt:|metis:[^\s]+\.obj|\bParMETIS_|\blibparmetis__') { throw 'Unapproved static Intel/METIS/ParMETIS implementation in Palace map' }
Write-Output "Remediated Palace candidate built: $build/palace.exe"
