[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$source = "$root/.work/sources/metis"
$build = "$root/.work/build/metis-remediation"
$candidate = "$root/.work/install/metis-remediation"
$tests = "$root/.work/build/metis-remediation-tests"

& cmake.exe -S $source -B $build -G Ninja -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl `
    '-DCMAKE_C_FLAGS=/D_WINDLL' `
    '-DCMAKE_CXX_FLAGS=/DWIN32 /D_CRT_SECURE_NO_DEPRECATE /EHsc /utf-8' `
    -DCMAKE_C_FLAGS_RELEASE=/O2 -DCMAKE_CXX_FLAGS_RELEASE=/O2 `
    -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL `
    "-DGKLIB_PATH=$source/GKlib" "-DCMAKE_INSTALL_PREFIX=$candidate" `
    -DMETIS_USE_LONGINDEX=OFF -DMETIS_USE_DOUBLEPRECISION=OFF `
    -DSHARED=ON -DASSERT=ON -DASSERT2=ON `
    '-DCMAKE_SHARED_LINKER_FLAGS=/MAP /VERBOSE:LIB /EXPORT:METIS_SETDEFAULTOPTIONS /EXPORT:METIS_NODEND'
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS configure failed' }
& cmake.exe --build $build --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS build failed' }
& cmake.exe --install $build
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS install failed' }

& cmake.exe -S "$root/tests/metis" -B $tests -G Ninja -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_CXX_COMPILER=cl -DCMAKE_CXX_FLAGS=/EHsc -DCMAKE_CXX_FLAGS_RELEASE=/O2 `
    -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL `
    "-DPW_METIS_PREFIX=$candidate" "-DPW_METIS_SOURCE=$source" "-DPW_METIS_BUILD=$build"
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS test configure failed' }
& cmake.exe --build $tests --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS test build failed' }
Copy-Item "$candidate/lib/metis.dll" $tests -Force
& ctest.exe --test-dir $tests --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Remediated METIS focused tests failed' }
Write-Output "Remediated METIS built and tested in isolated prefix: $candidate"
