[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Split-Path -Parent $PSScriptRoot).Replace('\','/')
$source = "$root/.work/sources/metis"
$build = "$root/.work/build/metis"
& cmake.exe -S $source -B $build -G Ninja -DCMAKE_C_COMPILER=cl -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_FLAGS_RELEASE=/O2 -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL `
    "-DGKLIB_PATH=$source/GKlib" "-DCMAKE_INSTALL_PREFIX=$root/.work/install/palace" `
    -DMETIS_USE_LONGINDEX=OFF -DMETIS_USE_DOUBLEPRECISION=OFF -DSHARED=OFF -DASSERT=ON -DASSERT2=ON
if ($LASTEXITCODE -ne 0) { throw "METIS configure failed: $LASTEXITCODE" }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw "METIS build failed: $LASTEXITCODE" }
& cmake.exe --install $build
if ($LASTEXITCODE -ne 0) { throw "METIS repository-local install failed: $LASTEXITCODE" }
& cmake.exe -S "$root/tests/metis" -B "$root/.work/build/metis-probe" -G Ninja `
    -DCMAKE_CXX_COMPILER=cl -DCMAKE_BUILD_TYPE=Release "-DPW_METIS_PREFIX=$root/.work/install/palace"
if ($LASTEXITCODE -ne 0) { throw "METIS probe configure failed: $LASTEXITCODE" }
& cmake.exe --build "$root/.work/build/metis-probe" --parallel 2
if ($LASTEXITCODE -ne 0) { throw "METIS probe build failed: $LASTEXITCODE" }
& ctest.exe --test-dir "$root/.work/build/metis-probe" --output-on-failure
if ($LASTEXITCODE -ne 0) { throw "METIS probe test failed: $LASTEXITCODE" }
