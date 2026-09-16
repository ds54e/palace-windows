[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$unicode=([char]0x65e5).ToString()+[char]0x672c+[char]0x8a9e
$package="$root/.work/gate4/Package $unicode"
if (Test-Path -LiteralPath $package) { throw 'Preserve existing Unicode package evidence' }
Copy-Item -LiteralPath "$root/.work/package/palace-windows-1.0.0" -Destination $package -Recurse
$output="$root/.work/gate4/Unicode package runs $unicode"
& "$PSScriptRoot/test-staged-package.ps1" -PackageDirectory $package -OutputRoot $output
$env:PATH="$env:WINDIR/System32;$env:WINDIR"
$env:OMP_NUM_THREADS='1';$env:MKL_NUM_THREADS='1'
& "$package/palace-sparams.exe" "$output/driven/output/port-S.csv" "$output/complex matrix.s2p" 50 1 2
if ($LASTEXITCODE -ne 0) { throw 'Staged exporter failed' }
$case="$output/electrostatic"
$config=Get-Content -LiteralPath "$case/config.json" -Raw | ConvertFrom-Json
$config.Solver.Linear.ColumnOrdering='ParMETIS'
$config.Problem.Output='unsupported-output'
$config | ConvertTo-Json -Depth 30 | Set-Content -Encoding UTF8 "$case/unsupported.json"
Push-Location $case
try {
    $info=New-Object Diagnostics.ProcessStartInfo
    $info.FileName="$package/palace.exe";$info.Arguments='unsupported.json';$info.WorkingDirectory=$case
    $info.UseShellExecute=$false;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    $p=[Diagnostics.Process]::Start($info)
    $out=$p.StandardOutput.ReadToEndAsync();$err=$p.StandardError.ReadToEndAsync()
    if (!$p.WaitForExit(60000)) { $p.Kill();throw 'Unsupported-ordering test timed out' }
    $text=$out.Result+$err.Result
    [IO.File]::WriteAllText("$case/unsupported.log",$text)
    if ($p.ExitCode -eq 0 -or $text -notmatch 'ParMETIS ordering is unsupported') { throw 'Unsupported-ordering behavior failed' }
} finally { Pop-Location }
Write-Output 'Unicode installation/output, complex exporter and explicit ParMETIS rejection passed on developer host.'
