[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
foreach ($name in @('json','json-schema-validator','fmt','scn','eigen')) {
    $options = switch ($name) {
      'json' { @('-DJSON_Install=ON','-DJSON_BuildTests=OFF') }
      'json-schema-validator' { @('-DJSON_VALIDATOR_INSTALL=ON','-DJSON_VALIDATOR_BUILD_TESTS=OFF','-DJSON_VALIDATOR_BUILD_EXAMPLES=OFF','-DJSON_VALIDATOR_SHARED_LIBS=OFF') }
      'fmt' { @('-DFMT_INSTALL=ON','-DFMT_DOC=OFF','-DFMT_TEST=OFF') }
      'scn' { @('-DSCN_INSTALL=ON','-DSCN_REGEX_BACKEND=std','-DSCN_DISABLE_TOP_PROJECT=ON') }
      'eigen' { @('-DEIGEN_BUILD_DOC=OFF','-DBUILD_TESTING=OFF','-DEIGEN_BUILD_TESTING=OFF','-DEIGEN_BUILD_BLAS=OFF','-DEIGEN_BUILD_LAPACK=OFF','-DEIGEN_BUILD_DEMOS=OFF') }
    }
    $build = "$root/.work/build/windows-$name"
    & cmake.exe -S "$root/.work/sources/$name" -B $build @common @options
    Complete-Build $build
}
