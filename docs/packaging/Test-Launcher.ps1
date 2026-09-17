[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PackageDirectory,
      [Parameter(Mandatory=$true)][string]$OutputRoot)
$ErrorActionPreference='Stop'
$package=(Resolve-Path -LiteralPath $PackageDirectory).Path
if(Test-Path -LiteralPath $OutputRoot){throw 'Choose a new launcher evidence directory'}
Copy-Item -LiteralPath "$package/examples/driven" -Destination $OutputRoot -Recurse
$work=(Resolve-Path -LiteralPath $OutputRoot).Path
$name='configuration '+([char]0x65e5).ToString()+[char]0x672c+[char]0x8a9e+' spaces.json'
Move-Item -LiteralPath "$work/config.json" -Destination "$work/$name"
$records=@()
foreach($inputName in @($name,'missing configuration.json')){
    $info=New-Object Diagnostics.ProcessStartInfo
    $info.FileName=Join-Path $env:WINDIR 'System32\cmd.exe'
    $info.Arguments='/d /s /c ""'+$package+'\Run-Palace.cmd" "'+$inputName+'""'
    $info.WorkingDirectory=$work;$info.UseShellExecute=$false
    $info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    $info.EnvironmentVariables['PATH']="$env:WINDIR\System32;$env:WINDIR"
    foreach($key in @('MSMPI_DISABLE_SOCK','MSMPI_DISABLE_ND','OMP_NUM_THREADS','MKL_NUM_THREADS')){$info.EnvironmentVariables.Remove($key)}
    $process=[Diagnostics.Process]::Start($info)
    $out=$process.StandardOutput.ReadToEndAsync();$err=$process.StandardError.ReadToEndAsync()
    if(!$process.WaitForExit(600000)){$process.Kill();throw 'Launcher timeout'}
    $text=$out.Result+$err.Result
    [IO.File]::WriteAllText("$work/$inputName.log",$text)
    if($inputName -eq $name -and $process.ExitCode -ne 0){throw 'Launcher solver failed'}
    if($inputName -ne $name -and ($process.ExitCode -eq 0 -or $text -notmatch 'missing configuration')){throw 'Launcher failed to propagate missing-input failure'}
    $records += [ordered]@{input=$inputName;exit_code=$process.ExitCode}
}
[ordered]@{scope='Launcher quoting, default environment and exit-code propagation';runs=$records} | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 "$work/launcher-report.json"
