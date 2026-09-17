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
    for name in ['README.txt','RUNTIME_TERMS.txt','REDISTRIBUTION_REVIEW.md','REDISTRIBUTION_MATRIX.json','REDISTRIBUTION_MATRIX.md','METIS_REPLACEMENT.txt','CLEAN_HOST_TEST.md','Test-CleanHost.ps1','Test-Paths.ps1','Test-Payload.ps1','Test-OutputFiles.ps1']:
        shutil.copy2(ROOT/'docs/packaging'/name,stage/name)

    for name in ['MicrosoftMPI_SDK_EULA.rtf', 'MPI_SDK_TPN.txt']:
        shutil.copy2(ROOT/'.work/extracted/sdk'/name, stage/'licenses/msmpi'/name)
    stl=stage/'licenses/microsoft-stl'; stl.mkdir(parents=True,exist_ok=True)
    for name in ['stl-license.txt', 'stl-license-source.json']:
        shutil.copy2(ROOT/'.work/licensing'/name,stl/name)
    evidence=stage/'licenses/microsoft-evidence'; evidence.mkdir(parents=True,exist_ok=True)
    for name in ['vs2022-community.docx','vs2022-community.json','vs2022-redist.html',
                 'vs2022-redist-source.json','vs-licensing-guidance.html','vs-licensing-guidance-source.json']:
        shutil.copy2(ROOT/'.work/licensing'/name,evidence/name)

def refresh_overlay_source(stage):
    for folder in ['deps','patches','cmake','scripts','src','tests','tools']:
        with tarfile.open(stage/'sources'/f'windows-overlay-{folder}.tar.gz','w:gz') as archive:
            names=subprocess.check_output(['git','ls-files','-z',folder],cwd=ROOT).decode().split('\0')
            for name in sorted(filter(None,names)):
                archive.add(ROOT/name,arcname=name,recursive=False)

if __name__=='__main__':
    raise SystemExit('Frozen candidates must not be refreshed in place. Prepare a new staging directory only after redistribution closure.')
