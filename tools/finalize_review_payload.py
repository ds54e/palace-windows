#!/usr/bin/env python3
"""Finalize unfrozen review staging from current scripts/notices; never mutate a ZIP.
Binary identities cannot change. All source archives get deterministic metadata.
"""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
from finalize_stage_notices import add_notices
from stage_windows_v1 import ROOT, STAGE
from render_redistribution_matrix import main as render

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def snapshot(source,output,prefix,subdir=None):
    args=['git','-C',str(source),'ls-files','-s','-z']
    if subdir:args+=['--',subdir]
    entries=subprocess.check_output(args).decode().split('\0')
    with output.open('wb') as raw,gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as compressed,tarfile.open(fileobj=compressed,mode='w|') as archive:
        for item in sorted(filter(None,entries)):
            metadata,name=item.split('\t',1);mode=metadata.split()[0];path=source/name
            if not path.is_file():continue
            info=tarfile.TarInfo(str(Path(prefix)/name));info.size=path.stat().st_size
            info.mode=0o755 if mode=='100755' else 0o644;info.mtime=0
            with path.open('rb') as stream:archive.addfile(info,stream)

def main():
    if (STAGE.parent/(STAGE.name+'-internal.zip')).exists():raise RuntimeError('Candidate ZIP is frozen; choose a new candidate identity')
    manifest=json.loads((STAGE/'build-manifest.json').read_text())
    for item in manifest['files']:
        if Path(item['path']).suffix.lower() in {'.exe','.dll'}:
            assert sha(STAGE/item['path'])==item['sha256'],item['path']
    add_notices(STAGE)
    for name in ['palace','mfem','metis','hypre','mumps','arpack-ng','libCEED','eigen','json','json-schema-validator','fmt','scn','fast_float']:
        snapshot(ROOT/'.work/sources'/name,STAGE/'sources'/f'{name}-corresponding-source.tar.gz',name)
    for folder in ['deps','patches','cmake','scripts','src','tests','tools','windows']:
        snapshot(ROOT,STAGE/'sources'/f'windows-overlay-{folder}.tar.gz','',folder)
    matrix=json.loads((ROOT/'docs/packaging/REDISTRIBUTION_MATRIX.json').read_text())
    matrix['package_fulfillment']={'status':'MECHANICALLY_COMPLETE','scope':'Exact internal payload; one legal determination remains pending',
        'payload_files':[dict(path=p.relative_to(STAGE).as_posix(),sha256=sha(p)) for p in sorted(STAGE.rglob('*')) if p.is_file() and (p.relative_to(STAGE).parts[0] in {'sources','licenses'} or p.suffix.lower() in {'.exe','.dll'})]}
    (ROOT/'docs/packaging/REDISTRIBUTION_MATRIX.json').write_text(json.dumps(matrix,indent=2)+'\n')
    render()
    for name in ['REDISTRIBUTION_MATRIX.json','REDISTRIBUTION_MATRIX.md']:
        (STAGE/name).write_bytes((ROOT/'docs/packaging'/name).read_bytes())
    review=STAGE/'REDISTRIBUTION_REVIEW.md';review.write_text(review.read_text().replace('../evidence/','docs/evidence/'))
    manifest['redistribution_matrix_sha256']=sha(STAGE/'REDISTRIBUTION_MATRIX.json')
    manifest['packaging_recipe_commit']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    manifest['packaging_recipe_files']={p.relative_to(ROOT).as_posix():sha(p) for p in (ROOT/'tools').glob('*.py')}
    manifest['files']=[dict(path=p.relative_to(STAGE).as_posix(),size=p.stat().st_size,sha256=sha(p)) for p in sorted(STAGE.rglob('*')) if p.is_file() and p.name!='build-manifest.json']
    (STAGE/'build-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('Unfrozen staging finalized; package verification and ZIP freezing remain required.')

if __name__=='__main__':main()
