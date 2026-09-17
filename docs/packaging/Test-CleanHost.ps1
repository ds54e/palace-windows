[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$OutputRoot,
    [switch]$AttestIndependentCleanHost,
    [switch]$AttestOffline
)
$ErrorActionPreference='Stop'
$package=$PSScriptRoot
if (!$AttestIndependentCleanHost -or !$AttestOffline) { throw 'Independent clean-host and offline attestations are required; a developer-host run cannot pass this test.' }
$identity=[Security.Principal.WindowsIdentity]::GetCurrent()
if (@($identity.Groups | Where-Object { $_.Value -eq 'S-1-5-32-544' }).Count) { throw 'Use a true standard account without Administrators group membership, including deny-only membership.' }
if (![Environment]::Is64BitOperatingSystem -or [Environment]::OSVersion.Version.Build -lt 22000) { throw 'This candidate targets Windows 11 x64.' }
if (Test-Path -LiteralPath $OutputRoot) { throw 'Choose a new output directory to preserve earlier evidence.' }
New-Item -ItemType Directory -Path $OutputRoot | Out-Null
$OutputRoot=(Resolve-Path -LiteralPath $OutputRoot).Path
Get-ExecutionPolicy -List | Out-File -Encoding utf8 "$OutputRoot/execution-policy.txt"
$manifest=Get-Content -LiteralPath "$package/build-manifest.json" -Raw | ConvertFrom-Json
foreach ($item in $manifest.files) {
    $path=Join-Path $package $item.path
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $item.sha256) { throw "Payload hash mismatch: $($item.path)" }
}
$vendor=@($manifest.files | Where-Object { $_.path -notmatch '[/\\]' -and $_.path -match '\.dll$' } | ForEach-Object { $_.path.ToLowerInvariant() })
$records=@()
foreach ($case in @('electrostatic','magnetostatic','driven','eigenmode')) {
    $work=Join-Path $OutputRoot $case
    Copy-Item -LiteralPath "$package/examples/$case" -Destination $work -Recurse
    $start=New-Object Diagnostics.ProcessStartInfo
    $start.FileName=Join-Path $package 'palace.exe'
    $start.Arguments='config.json'; $start.WorkingDirectory=$work
    $start.UseShellExecute=$false; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    $start.EnvironmentVariables['PATH']="$env:WINDIR\System32;$env:WINDIR"
    $start.EnvironmentVariables['OMP_NUM_THREADS']='1'; $start.EnvironmentVariables['MKL_NUM_THREADS']='1'
    $process=New-Object Diagnostics.Process; $process.StartInfo=$start
    [void]$process.Start()
    $stdout=$process.StandardOutput.ReadToEndAsync(); $stderr=$process.StandardError.ReadToEndAsync()
    $loaded=@{}; $timer=[Diagnostics.Stopwatch]::StartNew()
    while (!$process.HasExited) {
        $process.Refresh() # Process.Modules caches its collection; resample each poll.
        try { foreach ($module in $process.Modules) {
            $name=$module.ModuleName.ToLowerInvariant()
            if ($vendor -contains $name) { $loaded[$name]=$module.FileName }
        } } catch { if (!$process.HasExited) { throw } }
        if ($timer.Elapsed.TotalMinutes -gt 10) { $process.Kill(); throw "Case timeout: $case" }
        Start-Sleep -Milliseconds 50
    }
    $process.WaitForExit()
    [IO.File]::WriteAllText("$work/run.log",$stdout.Result + $stderr.Result)
    if ($process.ExitCode -ne 0) { throw "Case failed: $case exit=$($process.ExitCode)" }
    foreach ($name in $vendor) {
        if (!$loaded.ContainsKey($name)) { throw "Module observation missing: $case/$name" }
        if ([IO.Path]::GetFullPath($loaded[$name]) -ine [IO.Path]::GetFullPath((Join-Path $package $name))) { throw "Non-app-local module: $($loaded[$name])" }
    }
    $records += [ordered]@{case=$case;exit_code=$process.ExitCode;elapsed_seconds=$timer.Elapsed.TotalSeconds;vendor_modules=$loaded}
}
[ordered]@{
    status='AUTOMATED_SUBSET_COMPLETE_MANUAL_AND_NUMERICAL_REVIEW_REQUIRED'
    clean_host_attested=$true;offline_attested=$true;standard_user_checked=$true
    os_version=[Environment]::OSVersion.Version.ToString()
    manifest_sha256=(Get-FileHash "$package/build-manifest.json" -Algorithm SHA256).Hash.ToLowerInvariant()
    runs=$records
    remaining='CSV/VTK verification, interruption, re-run, read-only install path, uninstall and independent review; redistribution review'
} | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 "$OutputRoot/report.json"
Write-Output "Automated subset complete. Finish CLEAN_HOST_TEST.md; Gate 0 is not automatically passed. Evidence: $OutputRoot"
