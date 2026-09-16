[CmdletBinding()]
param([string]$Executable = '')
. "$PSScriptRoot/gate2-common.ps1"
$audit = "$root/.work/gate2/no-parmetis-audit"
New-Item -ItemType Directory -Force $audit | Out-Null
$records = @()
foreach ($file in Get-ChildItem "$prefix/lib" -Filter '*.lib' -File) {
    if ($file.Name -match 'parmetis') { throw "Forbidden library: $($file.FullName)" }
    $symbols = & dumpbin.exe /nologo /linkermember:1 $file.FullName 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Symbol inspection failed: $($file.FullName)" }
    $symbols | Set-Content -Encoding UTF8 "$audit/$($file.Name).symbols.txt"
    # MUMPS-owned disabled-feature stubs may contain 'mumps_parmetis'. Those
    # are not ParMETIS implementation symbols. Inspect actual vendor prefixes.
    $hits = @($symbols | Select-String -Pattern '\b(?:__imp_)?ParMETIS_|\blibparmetis__' -CaseSensitive)
    if ($hits.Count) { throw "ParMETIS implementation symbol in $($file.Name): $hits" }
    $records += [ordered]@{ path=$file.FullName.Replace('\','/').Replace("$root/",''); sha256=(Get-FileHash $file.FullName -Algorithm SHA256).Hash.ToLower(); parmetis_symbols=0 }
}
$configHits = @(Get-ChildItem $prefix -Recurse -Filter '*.cmake' | Select-String -Pattern '(?i)ParMETIS::|[/\\](?:lib)?parmetis\.(?:lib|dll|a)|[/\\]sources[/\\]parmetis[/\\]')
if ($configHits.Count) { throw "Exported ParMETIS dependency: $configHits" }
$imports = @()
if ($Executable) {
    if (-not (Test-Path -LiteralPath $Executable)) { throw "Missing executable: $Executable" }
    $imports = @(& dumpbin.exe /nologo /dependents $Executable 2>&1)
    if ($LASTEXITCODE -ne 0) { throw 'Import inspection failed' }
    if (@($imports | Select-String -Pattern '(?i)\bparmetis\.dll').Count) { throw 'Forbidden DLL import' }
    $imports | Set-Content -Encoding UTF8 "$audit/executable-imports.txt"
}
[ordered]@{ scope='Built prefix static-symbol/export audit; full dependency provenance and final runtime closure remain separate'; libraries=$records; exported_parmetis_dependencies=0; executable=$Executable; imports=$imports } | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 "$audit/report.json"
Write-Output "Audited $($records.Count) libraries: no ParMETIS implementation symbols or exported dependencies."
