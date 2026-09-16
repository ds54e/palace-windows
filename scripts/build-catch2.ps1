[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/windows-catch2"
& cmake.exe -S "$root/.work/sources/catch2" -B $build @common -DCMAKE_CXX_STANDARD=17 -DCATCH_BUILD_TESTING=OFF -DCATCH_INSTALL_DOCS=OFF -DCATCH_INSTALL_EXTRAS=ON
Complete-Build $build
