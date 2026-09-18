[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Split-Path -Parent $PSScriptRoot).Replace('\','/')
$source = "$root/.work/sources/metis"
$build = "$root/.work/build/metis-remediation"
$prefix = "$root/.work/install/metis-remediation"
$audit = "$root/.work/legal-remediation/audit/windows"
New-Item -ItemType Directory -Force $audit | Out-Null

$reference = Get-Content "$root/deps/metis-remediation-reference.json" -Raw | ConvertFrom-Json
$priorArt = @{
    'src/GKlib/sort.cc' = "$source/GKlib/sort.cc"
    'src/libmetis/gklib_sort.cc' = "$source/libmetis/gklib_sort.cc"
}
$provenance = @()
foreach ($entry in $reference.reference.files) {
    if ($priorArt.ContainsKey($entry.path)) {
        $actual = (Get-FileHash -LiteralPath $priorArt[$entry.path] -Algorithm SHA256).Hash.ToLower()
        if ($actual -ne $entry.sha256) { throw "Prior-art source hash mismatch: $($entry.path)" }
        $provenance += [ordered]@{ path=$entry.path; target=$priorArt[$entry.path].Replace("$root/",''); sha256=$actual; matches_pinned_reference=$true }
    }
}

$ninjaPath = "$build/build.ninja"
$mapPath = "$build/libmetis/metis.map"
$dllPath = "$prefix/lib/metis.dll"
$libPath = "$prefix/lib/metis.lib"
$ninja = Get-Content -LiteralPath $ninjaPath -Raw
$map = Get-Content -LiteralPath $mapPath
$linkLine = @($ninja -split "`r?`n" | Where-Object { $_ -match '^build libmetis\\metis\.dll ' })
if ($linkLine.Count -ne 1) { throw 'Could not identify the unique METIS DLL link statement' }

$excludedObjects = @('getopt.c.obj', 'gkregex.c.obj', 'sort.c.obj')
foreach ($name in $excludedObjects) {
    if ($linkLine[0] -match "(?:^|\\)$([regex]::Escape($name))(?: |$)") { throw "Excluded object linked: $name" }
}
foreach ($required in @('__\GKlib\sort.cc.obj', 'gklib_sort.cc.obj')) {
    if (-not $linkLine[0].Contains($required)) { throw "Replacement object missing from link: $required" }
}

$sourceRules = @($ninja -split "`r?`n" | Where-Object { $_ -match '^build libmetis\\CMakeFiles\\metis\.dir.*\.(?:c|cc)\.obj:' })
$forbiddenRules = @($sourceRules | Where-Object { $_ -match '\\(?:getopt|gkregex|sort)\.c\.obj:' })
if ($forbiddenRules.Count) { throw "Excluded source still compiled: $forbiddenRules" }

$forbiddenMap = @($map | Select-String -Pattern '(?:^|[\\/\s])(?:getopt|gkregex|sort)\.c\.obj(?:\s|$)' -CaseSensitive)
if ($forbiddenMap.Count) { throw "Excluded object present in map: $forbiddenMap" }
$vendorParmetis = @($map | Select-String -Pattern '\b(?:__imp_)?ParMETIS_|\blibparmetis__' -CaseSensitive)
if ($vendorParmetis.Count) { throw "ParMETIS implementation symbol present: $vendorParmetis" }

$selectedSorts = @('libmetis__ikvsortd','libmetis__ikvsorti','libmetis__rkvsortd')
$sortAttribution = @()
foreach ($symbol in $selectedSorts) {
    $hits = @($map | Select-String -Pattern "\s$([regex]::Escape($symbol))\s.*\sgklib_sort\.cc\.obj\s*$" -CaseSensitive)
    if ($hits.Count -ne 1) { throw "Final-map attribution failed for $symbol" }
    $sortAttribution += [ordered]@{ symbol=$symbol; final_object='gklib_sort.cc.obj'; map_line=$hits[0].Line.Trim() }
}
$inlinedStdSort = @($map | Select-String -Pattern '\?\?\$_(?:Sort|Guess_median|Partition_by_median).*gklib_sort\.cc\.obj\s*$' -CaseSensitive)
if (-not $inlinedStdSort.Count) { throw 'No C++ standard-library sort implementation attributed to replacement object' }

$objectReports = @()
foreach ($object in @(
    "$build/libmetis/CMakeFiles/metis.dir/__/GKlib/sort.cc.obj",
    "$build/libmetis/CMakeFiles/metis.dir/gklib_sort.cc.obj")) {
    $symbols = @(& dumpbin.exe /nologo /symbols $object 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "dumpbin symbols failed: $object" }
    $name = Split-Path -Leaf $object
    $outName = if ($object -match 'GKlib[/\\]sort') { 'GKlib-sort.cc.symbols.txt' } else { 'libmetis-gklib_sort.cc.symbols.txt' }
    $symbols | Set-Content -Encoding UTF8 "$audit/$outName"
    $objectReports += [ordered]@{ path=$object.Replace("$root/",''); sha256=(Get-FileHash $object -Algorithm SHA256).Hash.ToLower(); symbol_dump="$audit/$outName".Replace("$root/",'') }
}

$imports = @(& dumpbin.exe /nologo /dependents $dllPath 2>&1)
if ($LASTEXITCODE -ne 0) { throw 'dumpbin dependents failed for metis.dll' }
$imports | Set-Content -Encoding UTF8 "$audit/metis-dll-imports.txt"
$importNames = @($imports | Where-Object { $_ -match '^\s+[A-Za-z0-9_.-]+\.dll\s*$' } | ForEach-Object { $_.Trim().ToLower() } | Sort-Object -Unique)
if (@($importNames | Where-Object { $_ -match 'parmetis|gfortran|libgcc' }).Count) { throw "Unexpected METIS import: $importNames" }

$exports = @(& dumpbin.exe /nologo /exports $dllPath 2>&1)
if ($LASTEXITCODE -ne 0) { throw 'dumpbin exports failed for metis.dll' }
$exports | Set-Content -Encoding UTF8 "$audit/metis-dll-exports.txt"
foreach ($symbol in @('METIS_NodeND','METIS_PartGraphKway','METIS_PartGraphRecursive','METIS_SetDefaultOptions')) {
    if (-not @($exports | Select-String -SimpleMatch $symbol).Count) { throw "Required METIS export missing: $symbol" }
}

$report = [ordered]@{
    schema_version=1
    passed=$true
    target_commit=$reference.target.commit
    reference_commit=$reference.reference.commit
    source_rules=$sourceRules.Count
    linked_object_count=([regex]::Matches($linkLine[0], '\.(?:c|cc)\.obj')).Count
    excluded_objects=$excludedObjects
    excluded_compile_rules=0
    excluded_map_members=0
    parmetis_vendor_symbols=0
    replacement_provenance=$provenance
    selected_final_sort_symbols=$sortAttribution
    inlined_standard_sort_map_entries=$inlinedStdSort.Count
    objects=$objectReports
    dll=[ordered]@{ path=$dllPath.Replace("$root/",''); sha256=(Get-FileHash $dllPath -Algorithm SHA256).Hash.ToLower(); imports=$importNames }
    import_library=[ordered]@{ path=$libPath.Replace("$root/",''); sha256=(Get-FileHash $libPath -Algorithm SHA256).Hash.ToLower() }
    link_map=[ordered]@{ path=$mapPath.Replace("$root/",''); sha256=(Get-FileHash $mapPath -Algorithm SHA256).Hash.ToLower() }
    note='libmetis/parmetis.c is an upstream METIS translation unit; ParMETIS vendor symbols and artifacts are separately rejected.'
}
$report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 "$audit/report.json"
Write-Output "METIS remediation audit passed: $($sourceRules.Count) source rules, $($report.linked_object_count) linked objects, no excluded implementation or ParMETIS vendor symbols."
