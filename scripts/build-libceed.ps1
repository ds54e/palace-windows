[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/libceed-windows"
& cmake.exe -S "$root/cmake/libceed" -B $build -G Ninja -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_COMPILER=icx-cl -DCMAKE_C_FLAGS_RELEASE=/O2 -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL `
    "-DCEED_SOURCE=$root/.work/sources/libCEED" "-DCMAKE_INSTALL_PREFIX=$prefix"
Complete-Build $build
& ctest.exe --test-dir $build --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'libCEED connection tests failed' }
