[CmdletBinding()]
param([string]$OutputPath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This diagnostic must execute in native Windows PowerShell.'
}
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutputPath) { $OutputPath = Join-Path $root '.work\doctor\windows.json' }
function Find-Tool([string]$Name) {
    $item = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($item) { return $item.Source }
    return $null
}
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
try {
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $elevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} finally { $identity.Dispose() }
$tools = [ordered]@{}
foreach ($name in @('cmake.exe','ninja.exe','cl.exe','ifx.exe','git.exe','dumpbin.exe')) {
    $tools[$name] = Find-Tool $name
}
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = @()
if (Test-Path -LiteralPath $vswhere) {
    $raw = & $vswhere -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json
    if ($LASTEXITCODE -eq 0 -and $raw) {
        $vs = @(($raw -join "`n") | ConvertFrom-Json | Select-Object installationPath,installationVersion)
    }
}
$indicators = @()
foreach ($p in @('HKLM:\SOFTWARE\Microsoft\MPI','HKLM:\SOFTWARE\WOW6432Node\Microsoft\MPI',
    (Join-Path $env:SystemRoot 'System32\msmpi.dll'))) {
    if (Test-Path -LiteralPath $p) { $indicators += $p }
}
$services = @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(msmpi|smpd)' } | Select-Object Name,Status)
$report = [ordered]@{
    schema_version = 1
    recorded_utc = [DateTime]::UtcNow.ToString('o')
    native_windows = $true
    os_version = [Environment]::OSVersion.VersionString
    process_is_64bit = [Environment]::Is64BitProcess
    powershell_version = $PSVersionTable.PSVersion.ToString()
    elevated = $elevated
    tools_on_current_path = $tools
    visual_studio = $vs
    system_mpi_indicators = $indicators
    mpi_services = $services
    clean_host_proven = $false
    notes = 'Read-only inventory, not a toolchain compatibility or clean-host test. Missing PATH entries may need an already-installed developer shell.'
}
$full = [IO.Path]::GetFullPath($OutputPath)
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($full)) | Out-Null
[IO.File]::WriteAllText($full, ($report | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding($false)))
Write-Output "Wrote local diagnostic: $full"
Write-Output 'No tools were installed; no system settings were changed. Review local paths before sharing this report.'
