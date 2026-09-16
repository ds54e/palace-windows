[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$exe="$root/.work/build/palace-native/palace.exe"
$text=& $exe --licenses
if ($LASTEXITCODE -ne 0 -or ($text -join "`n") -notmatch 'MUMPS 5.7.3 under CeCILL-C') { throw 'Executable license-interface check failed' }
$text | Set-Content -Encoding UTF8 "$root/.work/gate4/licenses-option.log"
$text=& $exe --help
if ($LASTEXITCODE -ne 0 -or ($text -join "`n") -notmatch '\-\-licenses') { throw 'License option missing from help' }
& "$PSScriptRoot/run-gate3-windows.ps1"
& "$PSScriptRoot/audit-no-parmetis.ps1" -Executable $exe -LinkMap "$root/.work/build/palace-native/palace.map"
& "$PSScriptRoot/audit-runtime.ps1" -Executable $exe -OutputDirectory "$root/.work/gate4/runtime-audit"
