[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ProbeExe,
    [ValidateRange(1,600)][int]$TimeoutSeconds = 60,
    [switch]$CleanHostAttested
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Native Windows execution required.' }
$root = Split-Path -Parent $PSScriptRoot
$exe = (Resolve-Path -LiteralPath $ProbeExe).Path
$packageDir = [IO.Path]::GetDirectoryName($exe)
$runDir = Join-Path $root ('.work\gate0\' + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($runDir) | Out-Null
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
try {
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $elevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} finally { $identity.Dispose() }
$indicators = @()
foreach ($p in @('HKLM:\SOFTWARE\Microsoft\MPI','HKLM:\SOFTWARE\WOW6432Node\Microsoft\MPI',
    (Join-Path $env:SystemRoot 'System32\msmpi.dll'))) {
    if (Test-Path -LiteralPath $p) { $indicators += $p }
}
$services = @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(msmpi|smpd)' } | ForEach-Object { $_.Name })
$psi = New-Object Diagnostics.ProcessStartInfo
$psi.FileName = $exe
$psi.WorkingDirectory = $packageDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.StandardOutputEncoding = [Text.Encoding]::UTF8
$psi.StandardErrorEncoding = [Text.Encoding]::UTF8
$psi.EnvironmentVariables.Clear()
foreach ($name in @('SystemRoot','WINDIR','ComSpec','USERPROFILE','LOCALAPPDATA','HOMEDRIVE','HOMEPATH','USERNAME','USERDOMAIN')) {
    $v = [Environment]::GetEnvironmentVariable($name)
    if ($null -ne $v) { $psi.EnvironmentVariables[$name] = $v }
}
$psi.EnvironmentVariables['PATH'] = $packageDir + ';' + (Join-Path $env:SystemRoot 'System32')
$psi.EnvironmentVariables['TEMP'] = $runDir
$psi.EnvironmentVariables['TMP'] = $runDir
foreach ($name in @('OMP_NUM_THREADS','MKL_NUM_THREADS','OPENBLAS_NUM_THREADS')) { $psi.EnvironmentVariables[$name] = '1' }
$process = New-Object Diagnostics.Process
$process.StartInfo = $psi
$stdout = ''; $stderr = ''; $exitCode = -1; $timedOut = $false; $launchError = $null
try {
    [void]$process.Start()
    $outTask = $process.StandardOutput.ReadToEndAsync()
    $errTask = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) { $timedOut = $true; $process.Kill() }
    $process.WaitForExit()
    $stdout = $outTask.Result
    $stderr = $errTask.Result
    $exitCode = $process.ExitCode
} catch { $launchError = $_.Exception.Message }
finally { $process.Dispose() }
$encoding = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $runDir 'stdout.txt'), $stdout, $encoding)
[IO.File]::WriteAllText((Join-Path $runDir 'stderr.txt'), $stderr, $encoding)
$data = $null; $parseError = $null
try { $data = $stdout | ConvertFrom-Json } catch { $parseError = $_.Exception.Message }
$functional = $false; $appLocal = $false
if ($data -and $null -eq $launchError -and -not $timedOut -and $exitCode -eq 0) {
    try {
        $functional = ($data.status -eq 'pass' -and $data.rank -eq 0 -and $data.size -eq 1 -and $data.native_windows -eq $true -and $data.pointer_bits -eq 64)
        if ($data.msmpi_module) {
            $prefix = [IO.Path]::GetFullPath($packageDir).TrimEnd('\') + '\'
            $loaded = [IO.Path]::GetFullPath([string]$data.msmpi_module)
            $appLocal = $loaded.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
        }
    } catch { $parseError = $_.Exception.Message }
}
$candidate = $functional -and $appLocal -and -not $elevated -and $indicators.Count -eq 0 -and $services.Count -eq 0 -and $CleanHostAttested.IsPresent
$status = 'fail'
if ($functional) { $status = 'functional_only' }
if ($candidate) { $status = 'candidate_pass' }
$report = [ordered]@{
    schema_version = 1; recorded_utc = [DateTime]::UtcNow.ToString('o')
    status = $status; probe_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $exe).Hash.ToLowerInvariant()
    functional = $functional; app_local_msmpi = $appLocal; elevated = $elevated
    system_mpi_indicators = $indicators; mpi_services = $services
    clean_host_attested = $CleanHostAttested.IsPresent
    clean_host_automatically_proven = $false; redistribution_reviewed = $false
    timed_out = $timedOut; exit_code = $exitCode; launch_error = $launchError; parse_error = $parseError; probe = $data
    limitation = 'Candidate result only. Validate clean/offline host independently and review redistribution before passing G0.'
}
[IO.File]::WriteAllText((Join-Path $runDir 'report.json'), ($report | ConvertTo-Json -Depth 8), $encoding)
Write-Output "Gate 0 diagnostic: $status; local report: $runDir"
if (-not $functional) { exit 1 }
if (-not $candidate) { exit 2 }
exit 0
