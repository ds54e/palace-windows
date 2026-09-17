#!/usr/bin/env python3
"""Assemble an exact internal validation payload after numerical acceptance.
Does not declare redistribution permission, clean-host success or release readiness.
"""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
from finalize_stage_notices import add_notices

ROOT=Path(__file__).resolve().parents[1]
STAGE=ROOT/'.work/package/palace-windows-1.0.0-review2'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(source,target):
    source=Path(source); target=STAGE/target
    target.parent.mkdir(parents=True,exist_ok=True)
    if source.is_dir(): shutil.copytree(source,target)
    else: shutil.copy2(source,target)

def main():
    matrix=json.loads((ROOT/'docs/packaging/REDISTRIBUTION_MATRIX.json').read_text())
    if matrix['status'] != 'LEGAL_REVIEW_PENDING' or any(
        row['status'] != 'COMPONENT_REVIEW_COMPLETE' for row in matrix['components']):
        raise RuntimeError('Unreviewed component: internal packaging requires complete component records')
    comparison=json.loads((ROOT/'.work/redistribution/final-numerics/comparison.json').read_text())
    if not comparison['passed']: raise RuntimeError('Gate 3 numerical comparison has not passed')
    binding=json.loads((ROOT/'docs/evidence/G4-redistribution-linkage-2026-09-17.json').read_text())
    candidate=dict(status='pass',scope='Shared-METIS/listed-Intel developer-host validation',
                   windows_executable_sha256=binding['palace_sha256'],
                   comparison_sha256=sha(ROOT/'.work/redistribution/final-numerics/comparison.json'))
    if binding['comparison'] != comparison or candidate['windows_executable_sha256'] != sha(ROOT/'.work/build/palace-native/palace.exe'):
        raise RuntimeError('Current executable/comparison differs from frozen linkage evidence')
    if STAGE.exists(): raise RuntimeError('Staging directory already exists; preserve/review it before rebuilding')
    STAGE.mkdir(parents=True)
    evidence=json.loads((ROOT/'docs/evidence/G2-native-2026-09-17.json').read_text())
    runtime=binding['runtime']
    if runtime['files'] != matrix['binary_closure']:
        raise RuntimeError('Matrix and audited runtime closure differ')
    for item in runtime['files']:
        source=Path(subprocess.check_output(['wslpath','-u',item['source']],text=True).strip())
        if sha(source)!=item['sha256']: raise RuntimeError('Runtime identity changed: '+item['name'])
        copy(source,item['name'])
    exporter=json.loads((ROOT/'.work/gate3/sparams-runtime-audit/closure.json').read_text(encoding='utf-8-sig'))
    for item in exporter['files']:
        source=Path(subprocess.check_output(['wslpath','-u',item['source']],text=True).strip())
        if sha(source)!=item['sha256']: raise RuntimeError('Exporter runtime identity changed')
        target=STAGE/item['name']
        if target.exists():
            if sha(target)!=item['sha256']: raise RuntimeError('Conflicting runtime versions')
        else: copy(source,item['name'])
    for case in ['electrostatic','magnetostatic','driven','eigenmode']:
        p=ROOT/'.work/redistribution/final-numerics/windows'/case
        config=json.loads((p/'config.json').read_text())
        copy(p/'config.json',f'examples/{case}/config.json')
        copy(p/config['Model']['Mesh'],f'examples/{case}/'+config['Model']['Mesh'])
        for csv in (p/'output').glob('*.csv'): copy(csv,f'validation/windows/{case}/{csv.name}')
        for csv in (ROOT/'.work/gate3/linux'/case/'output').glob('*.csv'): copy(csv,f'validation/linux/{case}/{csv.name}')
    for name in ['palace','mfem','metis','hypre','mumps','arpack-ng','libCEED','eigen','json','json-schema-validator','fmt','scn','fast_float']:
        source=ROOT/'.work/sources'/name
        for p in source.iterdir():
            if any(term in p.name.upper() for term in ['LICENSE','COPYING','NOTICE']):
                copy(p,f'licenses/{name}/{p.name}')
        names=subprocess.check_output(['git','-C',str(source),'ls-files','-z']).decode().split('\0')
        target=STAGE/'sources'/f'{name}-corresponding-source.tar.gz'
        target.parent.mkdir(parents=True,exist_ok=True)
        with tarfile.open(target,'w:gz') as archive:
            for entry in sorted(filter(None,names)):
                p=source/entry
                if p.is_file(): archive.add(p,arcname=f'{name}/{entry}',recursive=False)
    mumps=ROOT/'.work/build/no-parmetis-mumps/mumps-src'
    for name in ['LICENSE','doc/CeCILL-C_V1-en.txt','doc/CeCILL-C_V1-fr.txt','PORD/README']:
        copy(mumps/name,'licenses/mumps/'+name)
    copy(ROOT/'.work/downloads/MUMPS_5.7.3.tar.gz','sources/MUMPS_5.7.3.tar.gz')
    mpi=ROOT/'.work/extracted/runtime-x64'
    for p in mpi.iterdir():
        if p.suffix.lower() in ['.rtf','.txt']: copy(p,'licenses/msmpi/'+p.name)
    for name,source in [
        ('intel-compiler',ROOT/'.work/deps/intel/share/doc/compiler/licensing/fortran'),
        ('mkl',ROOT/'.work/deps/mkl/share/doc/mkl/licensing'),
        ('mkl-cluster',ROOT/'.work/deps/mkl-cluster/share/doc/mkl/licensing')]:
        copy(source,'licenses/'+name)
    copy(ROOT/'.work/deps/intel/licensing/compiler/Intel Developer Tools EULA.rtf','licenses/intel-compiler/Intel Developer Tools EULA.rtf')
    copy(ROOT/'.work/deps/intel/share/doc/compiler/fredist.txt','licenses/intel-compiler/fredist.txt')
    for name in ['mkl','mkl-cluster']: copy(ROOT/f'.work/deps/{name}/license.txt',f'licenses/{name}/license.txt')
    for p in (ROOT/'.work/licensing').glob('*.docx'): copy(p,'licenses/microsoft-evidence/'+p.name)
    for p in (ROOT/'.work/licensing').glob('*-source.json'): copy(p,'licenses/microsoft-evidence/'+p.name)
    for name in ['README.txt','RUNTIME_TERMS.txt','REDISTRIBUTION_REVIEW.md','CLEAN_HOST_TEST.md','Test-CleanHost.ps1']: copy(ROOT/'docs/packaging'/name,name)
    copy(ROOT/'docs/GATE3_ACCEPTANCE.json','validation/GATE3_ACCEPTANCE.json')
    copy(ROOT/'docs/TOUCHSTONE.md','TOUCHSTONE.md')
    copy(ROOT/'LICENSE','licenses/windows-overlay/LICENSE')
    add_notices(STAGE)
    for name in ['G3-final-candidate-2026-09-17.json','G4-intel-package-2026-09-17.json','G4-microsoft-terms-2026-09-17.json','G4-redistribution-linkage-2026-09-17.json','VC-owner-entitlement-2026-09-17.json','G0-payload-2026-09-17.json']:
        copy(ROOT/'docs/evidence'/name,'docs/evidence/'+name)
    review=STAGE/'REDISTRIBUTION_REVIEW.md'
    review.write_text(review.read_text().replace('../evidence/','docs/evidence/'))
    for folder in ['deps','patches','cmake','scripts','src','tests','tools','windows']:
        with tarfile.open(STAGE/'sources'/f'windows-overlay-{folder}.tar.gz','w:gz') as archive:
            names=subprocess.check_output(['git','ls-files','-z',folder],cwd=ROOT).decode().split('\0')
            for name in sorted(filter(None,names)): archive.add(ROOT/name,arcname=name,recursive=False)
    manifest=dict(status='INTERNAL_RELEASE_REVIEW_CANDIDATE_LEGAL_REVIEW_PENDING', legal_review=matrix['legal_review'], redistribution_matrix_sha256=sha(ROOT/'docs/packaging/REDISTRIBUTION_MATRIX.json'),
        gate0='open: independent standard-user offline evidence and redistribution review pending',
        gate2_predecessor=evidence,windows_runtime=runtime,linux_identity=json.loads((ROOT/'.work/gate3/linux-identity.json').read_text()),
        comparison=comparison,candidate_validation=candidate,overlay_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        files=[dict(path=str(p.relative_to(STAGE)),size=p.stat().st_size,sha256=sha(p)) for p in sorted(STAGE.rglob('*')) if p.is_file()])
    (STAGE/'build-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(STAGE)

if __name__=='__main__': main()
