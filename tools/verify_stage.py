#!/usr/bin/env python3
"""Verify exact staged inventory; never infer clean-host or licensing approval."""
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
STAGE=ROOT/'.work/package/palace-windows-1.0.0-review2'

def main():
    manifest=json.loads((STAGE/'build-manifest.json').read_text())
    expected={i['path']:i for i in manifest['files']}
    actual={p.relative_to(STAGE).as_posix():p for p in STAGE.rglob('*') if p.is_file() and p.name!='build-manifest.json'}
    assert expected.keys()==actual.keys(),(expected.keys()-actual.keys(),actual.keys()-expected.keys())
    for name,p in actual.items():
        assert p.stat().st_size==expected[name]['size'],name
        assert hashlib.sha256(p.read_bytes()).hexdigest()==expected[name]['sha256'],name
    binaries={name.lower() for name in actual if Path(name).suffix.lower() in {'.exe','.dll','.lib','.obj','.a','.so'}}
    allowed={'palace.exe','palace-sparams.exe','metis.dll','libircmd.dll','msmpi.dll','libifcoremd.dll','libmmd.dll','svml_dispmd.dll','msvcp140.dll','vcruntime140.dll','vcruntime140_1.dll'}
    assert binaries==allowed,(binaries-allowed,allowed-binaries)
    assert manifest['comparison']['passed']
    for case in ['electrostatic','magnetostatic','driven','eigenmode']:
        p=STAGE/'examples'/case
        config=json.loads((p/'config.json').read_text())
        assert (p/config['Model']['Mesh']).is_file(),case
    result=dict(scope='Exact payload inventory/hashes only; no redistribution or clean-host pass',files=len(actual)+1,bytes=sum(p.stat().st_size for p in actual.values())+(STAGE/'build-manifest.json').stat().st_size,binaries=sorted(binaries),status='pass')
    (STAGE.parent/(STAGE.name+'-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))

if __name__=='__main__': main()
