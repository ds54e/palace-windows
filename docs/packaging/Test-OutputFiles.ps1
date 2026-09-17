[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$CaseRoot)
$ErrorActionPreference='Stop'
$culture=[Globalization.CultureInfo]::InvariantCulture
$records=@()
foreach($case in @('electrostatic','magnetostatic','driven','eigenmode')) {
    $folder=Join-Path $CaseRoot "$case/output"
    $csv=@(Get-ChildItem -LiteralPath $folder -Filter '*.csv' -File)
    $vtk=@(Get-ChildItem -LiteralPath $folder -Filter '*.vtu' -File -Recurse)
    if(!$csv.Count -or !$vtk.Count){throw "Missing CSV/VTU: $case"}
    foreach($f in $csv){
        $lines=[IO.File]::ReadAllLines($f.FullName)
        if($lines.Count -lt 2){throw "Empty CSV: $f"}
        $headers=@($lines[0].Split(',') | ForEach-Object {$_.Trim()})
        foreach($line in $lines[1..($lines.Count-1)]){
            $cells=$line.Split(',');if($cells.Count -ne $headers.Count){throw "Ragged CSV: $f"}
            for($i=0;$i -lt $cells.Count;$i++){
                $number=0.0
                if(![double]::TryParse($cells[$i].Trim(),[Globalization.NumberStyles]::Float,$culture,[ref]$number)){
                    # C++ prints inf; only the predeclared lossless eigenmode Q exception is allowed.
                    $imag=[Array]::IndexOf($headers,'Im{f} (GHz)')
                    if($case -eq 'eigenmode' -and $headers[$i] -eq 'Q' -and $cells[$i].Trim() -match '^\+?inf$' -and $imag -ge 0 -and [double]::Parse($cells[$imag],$culture) -eq 0){continue}
                    throw "Nonnumeric CSV: $f column $i"
                }
                if([double]::IsNaN($number) -or [double]::IsInfinity($number)){throw "Nonfinite CSV: $f"}
            }
        }
    }
    foreach($f in $vtk){
        $bytes=[IO.File]::ReadAllBytes($f.FullName)
        $text=[Text.Encoding]::GetEncoding(28591).GetString($bytes)
        $marker='<AppendedData encoding="raw">';$start=$text.IndexOf($marker);$payload=0
        if($start -ge 0){$payload=$text.IndexOf('_',$start)+1;$end=$text.LastIndexOf('</AppendedData>');if($end -le $payload){throw 'Invalid appended data'};$text=$text.Substring(0,$start)+$text.Substring($end+15)}
        [xml]$xml=$text
        if($xml.VTKFile.byte_order -ne 'LittleEndian' -or $xml.VTKFile.HasAttribute('compressor')){throw 'Unexpected VTU encoding'}
        $width=4;if($xml.VTKFile.header_type -eq 'UInt64'){$width=8}
        foreach($array in $xml.SelectNodes('//DataArray')){
            if($array.format -eq 'ascii'){
                foreach($v in ($array.InnerText.Trim() -split '\s+')){if($v -and ([double]::IsNaN([double]::Parse($v,$culture)) -or [double]::IsInfinity([double]::Parse($v,$culture)))){throw 'Nonfinite VTU'}}
                continue
            }
            if($array.format -eq 'appended'){
                $offset=$payload+[long]$array.offset
                $length=if($width -eq 8){[BitConverter]::ToUInt64($bytes,$offset)}else{[BitConverter]::ToUInt32($bytes,$offset)}
                if($offset+$width+$length -gt $end){throw 'Truncated VTU array'}
                $values=$bytes;$begin=$offset+$width
            }elseif($array.format -eq 'binary'){
                $encoded=$array.InnerText -replace '\s','';$chars=4*[int][Math]::Ceiling($width/3.0)
                $header=[Convert]::FromBase64String($encoded.Substring(0,$chars))
                $length=if($width -eq 8){[BitConverter]::ToUInt64($header,0)}else{[BitConverter]::ToUInt32($header,0)}
                $values=[Convert]::FromBase64String($encoded.Substring($chars));$begin=0
                if($values.Length -ne $length){throw 'VTU array length mismatch'}
            }else{throw 'Unsupported VTU format'}
            $stride=0;if($array.type -eq 'Float64'){$stride=8}elseif($array.type -eq 'Float32'){$stride=4}
            if($stride){
                if($length % $stride){throw 'Misaligned VTU float array'}
                for($i=$begin;$i -lt $begin+$length;$i+=$stride){
                    $v=if($stride -eq 8){[BitConverter]::ToDouble($values,$i)}else{[BitConverter]::ToSingle($values,$i)}
                    if([double]::IsNaN($v) -or [double]::IsInfinity($v)){throw 'Nonfinite VTU array'}
                }
            }
        }
    }
    foreach($f in Get-ChildItem -LiteralPath $folder -Recurse -File | Where-Object {$_.Extension -in @('.pvtu','.pvd')}){
        [xml]$xml=[IO.File]::ReadAllText($f.FullName)
        foreach($node in $xml.SelectNodes('//*[@file or @Source]')){
            $target=$node.GetAttribute('file');if(!$target){$target=$node.GetAttribute('Source')}
            if(!(Test-Path -LiteralPath (Join-Path $f.DirectoryName $target) -PathType Leaf)){throw "Missing VTK reference: $target"}
        }
    }
    $records += [ordered]@{case=$case;csv_count=$csv.Count;vtu_count=$vtk.Count;structure_and_finite_values='pass'}
}
$records | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 (Join-Path $CaseRoot 'output-structure.json')
Write-Output 'CSV/VTU structure and finite values passed; numerical comparison remains a separate check.'
