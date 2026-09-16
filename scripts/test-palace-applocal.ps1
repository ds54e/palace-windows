[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$closure = Get-Content -Raw "$root/.work/gate2/runtime-audit/closure.json" | ConvertFrom-Json
$unicode = ([char]0x65e5).ToString() + [char]0x672c + [char]0x8a9e
$stage = "$root/.work/staging/Palace V1 $unicode"
$case = "$root/.work/gate2/Windows paths $unicode"
New-Item -ItemType Directory -Force $stage, "$case/mesh" | Out-Null
foreach ($file in $closure.files) {
    Copy-Item -LiteralPath $file.source -Destination "$stage/$($file.name)" -Force
    if ((Get-FileHash -LiteralPath "$stage/$($file.name)" -Algorithm SHA256).Hash.ToLower() -ne $file.sha256) { throw 'Staging hash mismatch' }
}
Copy-Item "$root/.work/gate2/palace-smoke/electrostatic/config.json" "$case/config.json" -Force
Copy-Item "$root/.work/gate2/palace-smoke/electrostatic/mesh/*" "$case/mesh" -Force
$oldPath=$env:PATH
$env:PATH="$env:WINDIR/System32;$env:WINDIR"
$env:OMP_NUM_THREADS='1'; $env:MKL_NUM_THREADS='1'
$loaded=@{}
try {
    function Start-Palace([string]$inputFile) {
        $info = New-Object System.Diagnostics.ProcessStartInfo
        $info.FileName = "$stage/palace.exe"
        $info.Arguments = $inputFile
        $info.WorkingDirectory = $case
        $info.UseShellExecute = $false
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $p = [Diagnostics.Process]::Start($info)
        return $p
    }
    $process = Start-Palace 'config.json'
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $deadline = [DateTime]::UtcNow.AddMinutes(2)
    while (-not $process.HasExited) {
        try { foreach ($module in $process.Modules) { $loaded[$module.ModuleName.ToLowerInvariant()]=$module.FileName } } catch { }
        Start-Sleep -Milliseconds 50
        $process.Refresh()
        if ([DateTime]::UtcNow -gt $deadline) { $process.Kill(); throw 'Staged smoke timed out' }
    }
    $stdout.Result | Set-Content -Encoding UTF8 "$case/stdout.log"
    $stderr.Result | Set-Content -Encoding UTF8 "$case/stderr.log"
    if ($process.ExitCode -ne 0) { throw "Staged Palace failed: $($process.ExitCode)" }
    Write-Output 'Staged solver exited successfully; checking loaded modules.'
    foreach ($file in $closure.files) {
        if ($file.name -eq 'palace.exe') { continue }
        if (-not $loaded.ContainsKey($file.name)) { throw "Runtime loading not observed: $($file.name)" }
        if ([IO.Path]::GetFullPath($loaded[$file.name]) -ne [IO.Path]::GetFullPath("$stage/$($file.name)")) { throw "Runtime loaded outside stage: $($file.name)" }
    }
    $config=Get-Content -Raw "$case/config.json" | ConvertFrom-Json
    $config.Solver.Linear.ColumnOrdering='ParMETIS'
    $config | ConvertTo-Json -Depth 30 | Set-Content -Encoding UTF8 "$case/unsupported.json"
    $negative = Start-Palace 'unsupported.json'
    $negativeOut = $negative.StandardOutput.ReadToEndAsync()
    $negativeErr = $negative.StandardError.ReadToEndAsync()
    if (-not $negative.WaitForExit(60000)) { $negative.Kill(); throw 'Unsupported-ordering check timed out' }
    $negativeOut.Result | Set-Content -Encoding UTF8 "$case/unsupported-stdout.log"
    $diagnostic = $negativeErr.Result
    $diagnostic | Set-Content -Encoding UTF8 "$case/unsupported-stderr.log"
    if ($negative.ExitCode -eq 0 -or $diagnostic -notmatch 'ParMETIS ordering is unsupported in the Windows V1 build') { throw 'Missing explicit unsupported-ordering failure' }
    [ordered]@{ scope='Developer-host restricted-PATH app-local run, not clean-host proof'; stage=$stage; case=$case; exit_code=$process.ExitCode; loaded_modules=$loaded; parmetis_exit_code=$negative.ExitCode; parmetis_diagnostic=$diagnostic } | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 "$root/.work/gate2/palace-applocal.json"
} finally { $env:PATH=$oldPath }
Write-Output 'Staged Unicode/space-path solve and explicit ParMETIS rejection passed.'
