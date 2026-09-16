[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Executable)
. "$PSScriptRoot/gate2-common.ps1"
$audit = "$root/.work/gate2/runtime-audit"
New-Item -ItemType Directory -Force $audit | Out-Null
$redist = Join-Path $env:VCToolsRedistDir 'x64/Microsoft.VC143.CRT'
$search = @((Split-Path -Parent $Executable), "$root/.work/staging/mpi-probe", "$root/.work/deps/intel/Library/bin", $redist)
$queue = New-Object 'System.Collections.Generic.Queue[string]'
$queue.Enqueue((Resolve-Path -LiteralPath $Executable).Path)
$seen = @{}; $records = @(); $os = @{}
while ($queue.Count) {
    $path = $queue.Dequeue()
    $name = [IO.Path]::GetFileName($path).ToLowerInvariant()
    if ($seen.ContainsKey($name)) { continue }
    $seen[$name] = $true
    $lines = @(& dumpbin.exe /nologo /dependents $path 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Import audit failed: $path" }
    $lines | Set-Content -Encoding UTF8 "$audit/$name.imports.txt"
    $deps = @($lines | ForEach-Object { if ($_ -match '^\s+([A-Za-z0-9_.-]+\.dll)\s*$') { $matches[1].ToLowerInvariant() } } | Sort-Object -Unique)
    if (@($deps | Where-Object { $_ -match 'parmetis' }).Count) { throw "Forbidden ParMETIS import: $path" }
    $records += [ordered]@{ name=$name; source=$path.Replace('\','/'); sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower(); size=(Get-Item -LiteralPath $path).Length; imports=$deps }
    foreach ($dep in $deps) {
        if ($seen.ContainsKey($dep)) { continue }
        if ($dep -match '^(api-ms-win-|ext-ms-win-)') { $os[$dep]='Windows API set'; continue }
        $found = $null
        foreach ($directory in $search) {
            $candidate = Join-Path $directory $dep
            if (Test-Path -LiteralPath $candidate) { $found=$candidate; break }
        }
        if ($found) { $queue.Enqueue($found); continue }
        if ($dep -match '^(vcruntime|msvcp|concrt|libif|libmmd|svml|msmpi)') { throw "Required app-local vendor runtime not found: $dep" }
        if (Test-Path -LiteralPath (Join-Path "$env:WINDIR/System32" $dep)) { $os[$dep]='Windows system DLL'; continue }
        throw "Unresolved import $dep required by $name"
    }
}
[ordered]@{ scope='Recursive PE import closure on developer host; delay/dynamic-load and clean-host validation still required'; executable=$Executable; files=$records; operating_system_imports=$os; redistribution_review='pending' } | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 "$audit/closure.json"
Write-Output "Recorded $($records.Count) executable/runtime files and $($os.Count) Windows imports."
