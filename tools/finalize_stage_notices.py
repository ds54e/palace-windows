#!/usr/bin/env python3
"""Add exact reviewed notices; leave unresolved obligations explicit."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[1]

def add_notices(stage):
    target=stage/'licenses/metis/GKlib'; target.mkdir(parents=True,exist_ok=True)
    for name in ['gk_mksort.h','getopt.c','gkregex.c','gkregex.h','ms_stdint.h','ms_inttypes.h','random.c']:
        shutil.copy2(ROOT/'.work/sources/metis/GKlib'/name,target/name)
    for name in ['LGPL-2.1.txt','lgpl-source.json']:
        shutil.copy2(ROOT/'.work/licensing'/name,target/name)
    for name in ['README.txt','RUNTIME_TERMS.txt','REDISTRIBUTION_REVIEW.md','CLEAN_HOST_TEST.md','Test-CleanHost.ps1']:
        shutil.copy2(ROOT/'docs/packaging'/name,stage/name)

def refresh_overlay_source(stage):
    for folder in ['deps','patches','cmake','scripts','src','tests','tools']:
        with tarfile.open(stage/'sources'/f'windows-overlay-{folder}.tar.gz','w:gz') as archive:
            names=subprocess.check_output(['git','ls-files','-z',folder],cwd=ROOT).decode().split('\0')
            for name in sorted(filter(None,names)):
                archive.add(ROOT/name,arcname=name,recursive=False)

if __name__=='__main__':
    stage=ROOT/'.work/package/palace-windows-1.0.0'
    manifest=json.loads((stage/'build-manifest.json').read_text())
    # Notice-only refresh: executable/runtime hashes must remain unchanged.
    for item in manifest['files']:
        if Path(item['path']).suffix.lower() in {'.exe','.dll'}:
            assert hashlib.sha256((stage/item['path']).read_bytes()).hexdigest()==item['sha256']
    add_notices(stage)
    refresh_overlay_source(stage)
    manifest['packaging_recipe_commit']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    manifest['files']=[dict(path=p.relative_to(stage).as_posix(),size=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in sorted(stage.rglob('*')) if p.is_file() and p.name!='build-manifest.json']
    manifest['notice_review']='VC entitlement, Intel embedded support grant and LGPL static-combination obligations unresolved; no redistribution approval'
    (stage/'build-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
