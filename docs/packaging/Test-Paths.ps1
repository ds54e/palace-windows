[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PackageDirectory,
      [Parameter(Mandatory=$true)][string]$OutputRoot,
      [switch]$DeveloperHost,[switch]$AttestIndependentCleanHost,[switch]$AttestOffline)
$ErrorActionPreference='Stop'
$package=(Resolve-Path -LiteralPath $PackageDirectory).Path
$kit=$PSScriptRoot
if(!$DeveloperHost){
    if(!$AttestIndependentCleanHost -or !$AttestOffline){throw 'Independent clean/offline attestations required'}
    $identity=[Security.Principal.WindowsIdentity]::GetCurrent()
    if(@($identity.Groups | Where-Object {$_.Value -eq 'S-1-5-32-544'}).Count){throw 'A true standard account is required, including no deny-only Administrators membership'}
    if(![Environment]::Is64BitOperatingSystem -or [Environment]::OSVersion.Version.Build -lt 22000){throw 'Windows 11 x64 required'}
}
if(Test-Path -LiteralPath $OutputRoot){throw 'Use a new output directory'}
$destination=[IO.Path]::GetFullPath($OutputRoot)
if($destination.StartsWith($package+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Output root must be outside the package'}
New-Item -ItemType Directory -Path $destination | Out-Null
Get-ExecutionPolicy -List | Out-File -Encoding utf8 "$destination/execution-policy.txt"
$products=@(Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -match 'Visual Studio|oneAPI|Intel.*(Fortran|Compiler|Runtime)|Microsoft MPI|MS-MPI|Python|Windows Subsystem for Linux'} | Select-Object DisplayName,DisplayVersion)
$services=@(Get-Service smpd,WslService,LxssManager -ErrorAction SilentlyContinue | Select-Object Name,Status)
[ordered]@{products=$products;services=$services;scope='Read-only bounded inventory; independent image preparation attestation is also required'} | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 "$destination/host-inventory.json"
if(!$DeveloperHost -and ($products.Count -or $services.Count)){throw 'Host contains excluded developer/runtime/WSL installations; preserve inventory and use an independent clean image'}
$unicode=([char]0x65e5).ToString()+[char]0x672c+[char]0x8a9e
$variants=@('PalaceASCII','Palace test',"Palace $unicode")
$records=@()
foreach($variant in $variants){
    $base=Join-Path $destination $variant;New-Item -ItemType Directory $base | Out-Null
    $copy=Join-Path $base 'application';Copy-Item -LiteralPath $package -Destination $copy -Recurse
    $first=Join-Path $base 'run1'
    & "$kit/Test-Payload.ps1" -PackageDirectory $copy -OutputRoot $first
    & "$kit/Test-OutputFiles.ps1" -CaseRoot $first
    $negative=@()
    $work=Join-Path $first 'electrostatic'
    $config=Get-Content -LiteralPath "$work/config.json" -Raw | ConvertFrom-Json
    $config.Solver.Linear.ColumnOrdering='ParMETIS';$config.Problem.Output='unsupported-output'
    [IO.File]::WriteAllText("$work/unsupported.json",($config | ConvertTo-Json -Depth 30))
    foreach($file in @('missing-configuration.json','unsupported.json')){
        $info=New-Object Diagnostics.ProcessStartInfo
        $info.FileName="$copy/palace.exe";$info.Arguments=$file;$info.WorkingDirectory=$work
        $info.UseShellExecute=$false;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
        $info.EnvironmentVariables['PATH']="$env:WINDIR\System32;$env:WINDIR"
        $info.EnvironmentVariables['OMP_NUM_THREADS']='1';$info.EnvironmentVariables['MKL_NUM_THREADS']='1'
        $process=[Diagnostics.Process]::Start($info);$out=$process.StandardOutput.ReadToEndAsync();$err=$process.StandardError.ReadToEndAsync()
        if(!$process.WaitForExit(60000)){$process.Kill();throw "Negative test timeout: $file"}
        $text=$out.Result+$err.Result;[IO.File]::WriteAllText("$work/$file.log",$text)
        if($process.ExitCode -eq 0){throw "Expected failure: $file"}
        if($file -eq 'unsupported.json' -and $text -notmatch 'ParMETIS ordering is unsupported'){throw 'Missing unsupported-ordering diagnostic'}
        if($file -eq 'missing-configuration.json' -and $text -notmatch 'missing-configuration|[Ff]ile|[Cc]onfiguration'){throw 'Missing configuration diagnostic'}
        $negative += [ordered]@{configuration=$file;exit_code=$process.ExitCode;clear_failure=$true}
    }
    $second=Join-Path $base 'run2'
    & "$kit/Test-Payload.ps1" -PackageDirectory $copy -OutputRoot $second
    & "$kit/Test-OutputFiles.ps1" -CaseRoot $second
    & "$copy/palace-sparams.exe" "$second/driven/output/port-S.csv" "$base/ports.s2p" 50 1 2
    if($LASTEXITCODE -ne 0){throw 'Touchstone export failed'}
    $records += [ordered]@{path_class=$variant;first_run=$first;repeat_and_recovery=$second;failures=$negative;touchstone='pass'}
}
[ordered]@{
    scope=$(if($DeveloperHost){'DEVELOPER_HOST_ONLY'}else{'INDEPENDENT_STANDARD_USER_OFFLINE_AUTOMATED_SUBSET'})
    clean_host_attested=(!$DeveloperHost -and [bool]$AttestIndependentCleanHost)
    offline_attested=(!$DeveloperHost -and [bool]$AttestOffline)
    standard_user_checked=(!$DeveloperHost)
    os_version=[Environment]::OSVersion.Version.ToString();runs=$records
    remaining='Independent preparation record, network-attempt observation, Ctrl+C and cleanup/uninstall evidence, returned-data numerical review; no automatic Gate 0 pass'
} | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 "$destination/path-report.json"
Write-Output "Three path classes, four solvers, repeat/recovery, negative cases and CSV/VTU structure completed: $destination"
