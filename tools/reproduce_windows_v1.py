#!/usr/bin/env python3
"""Fresh Windows build tree from pinned sources and reverified archive inputs.
Copies no extracted SDK/compiler tree, generated build file, object or library.
The installed MSVC/Windows SDK and 7-Zip are declared host prerequisites.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
def run(*args): subprocess.run(list(map(str,args)),check=True)
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        while b:=f.read(1024*1024):h.update(b)
    return h.hexdigest()
def win(p):return subprocess.check_output(['wslpath','-w',str(p)],text=True).strip()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--destination',type=Path,required=True)
    args=parser.parse_args(); dest=args.destination.resolve()
    if dest.exists():raise RuntimeError('Choose an empty new reproduction destination')
    run('git','clone','--no-hardlinks',ROOT,dest)
    commit=subprocess.check_output(['git','-C',str(dest),'rev-parse','HEAD'],text=True).strip()
    work=dest/'.work'; (work/'downloads').mkdir(parents=True)
    locks=[json.loads((dest/'deps'/n).read_text()) for n in ['gate1-lock.json','gate2-lock.json']]
    items=locks[0]['packages']+[locks[0]['mumps_source'],locks[1]['compiler_supplement']]+locks[1]['mfem_upstream_patches']
    g0=json.loads((dest/'docs/evidence/G0-payload-2026-09-17.json').read_text())
    for name in ['msmpisetup.exe','msmpisdk.msi']:
        f=next(f for f in g0['files'] if f['path']=='.work/downloads/'+name)
        items.append(dict(filename=name,sha256=f['sha256']))
    reused=[]
    for item in items:
        source=ROOT/'.work/downloads'/item['filename']
        if source.exists():
            if sha(source)!=item['sha256']:raise RuntimeError('Archive digest mismatch: '+str(source))
            target=work/'downloads'/source.name;shutil.copy2(source,target)
            if sha(target)!=item['sha256']:raise RuntimeError('Copied archive digest mismatch')
            reused.append(dict(filename=source.name,sha256=item['sha256']))
    palace=work/'sources/palace';palace.mkdir(parents=True)
    upstream=json.loads((dest/'deps/upstream.json').read_text())['palace']
    run('git','-C',palace,'init','-q')
    run('git','-C',palace,'fetch','--depth','1',upstream['repository'],upstream['commit'])
    run('git','-C',palace,'checkout','--detach',upstream['commit'])
    run(sys.executable,dest/'tools/prepare_gate1.py')
    run(sys.executable,dest/'tools/prepare_gate2.py')
    seven=Path('/mnt/c/Program Files/7-Zip/7z.exe')
    if not seven.is_file():raise RuntimeError('Declared host extraction prerequisite 7-Zip unavailable')
    run(seven,'x','-y','-o'+win(work/'extracted/sdk'),win(work/'downloads/msmpisdk.msi'))
    # Restore the x64 installation alias from the exact SDK member bytes.
    shutil.copy2(work/'extracted/sdk/mpifptr64.h',work/'extracted/sdk/mpifptr.h')
    installer=(work/'downloads/msmpisetup.exe').read_bytes()
    assert installer[3449344:3449352]==bytes.fromhex('d0cf11e0a1b11ae1')
    embedded=work/'downloads/msmpi-runtime-x64.msi';embedded.write_bytes(installer[3449344:])
    run(seven,'x','-y','-o'+win(work/'extracted/runtime-x64'),win(embedded))
    stage=work/'staging/mpi-probe';stage.mkdir(parents=True)
    shutil.copy2(work/'extracted/runtime-x64/msmpi64.dll',stage/'msmpi.dll')
    manifest=dict(scope='Fresh extracted tools, source trees, build and install directories; only hash-verified immutable downloads reused',recipe_commit=commit,source='pinned upstream network fetches',reused_archives=reused,host_prerequisites=['installed MSVC 19.44.35219 / Windows SDK','installed 7-Zip'],build='not_started')
    (work/'reproduction-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('FRESH_INPUTS_READY',dest,flush=True)
    command=win(dest/'tools/native-dev.cmd')+' powershell.exe -NoProfile -ExecutionPolicy Bypass -File '+win(dest/'scripts/build-windows-v1.ps1')
    run('cmd.exe','/d','/c',command)
    manifest['build']='completed';(work/'reproduction-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')

if __name__=='__main__':main()
