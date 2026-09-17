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
    matrix=json.loads((STAGE/'REDISTRIBUTION_MATRIX.json').read_text())
    assert matrix['status']=='LEGAL_REVIEW_PENDING'
    assert matrix['legal_review']['id']=='LGPL_INTEL_COMBINED_WORK'
    assert all(r['status']=='COMPONENT_REVIEW_COMPLETE' for r in matrix['components'])
    assert hashlib.sha256((STAGE/'REDISTRIBUTION_MATRIX.json').read_bytes()).hexdigest()==manifest['redistribution_matrix_sha256']
    for item in matrix['binary_closure']:
        assert hashlib.sha256((STAGE/item['name']).read_bytes()).hexdigest()==item['sha256'],item['name']
    required={
        'palace':['LICENSE','NOTICE'], 'mfem':['LICENSE','NOTICE'],
        'hypre':['LICENSE-APACHE','LICENSE-MIT','NOTICE'], 'metis':['LICENSE.txt','GKlib/LGPL-2.1.txt','GKlib/gk_mksort.h','GKlib/getopt.c','GKlib/gkregex.c','GKlib/gkregex.h'],
        'mumps':['LICENSE','doc/CeCILL-C_V1-en.txt','doc/CeCILL-C_V1-fr.txt','PORD/README'],
        'arpack-ng':['COPYING'], 'libCEED':['LICENSE','NOTICE'],
        'msmpi':['MicrosoftMPI_SDK_EULA.rtf','MPI_SDK_TPN.txt','MicrosoftMPI_Redistributable_EULA.rtf','MPI_Redistributables_TPN.txt'],
        'intel-compiler':['Intel Developer Tools EULA.rtf','fredist.txt','third-party-programs.txt'],
        'mkl':['license.txt','third-party-programs.txt'], 'mkl-cluster':['license.txt','third-party-programs.txt'],
        'microsoft-stl':['stl-license.txt'],
        'microsoft-evidence':['vs2022-community.docx','vs2022-redist.html','vc-runtime.docx','vs-licensing-guidance.html']}
    for component,names in required.items():
        for name in names:assert (STAGE/'licenses'/component/name).is_file(),(component,name)
    for name in ['palace','mfem','hypre','metis','mumps','arpack-ng','libCEED','eigen','json','json-schema-validator','fmt','scn','fast_float']:
        assert (STAGE/'sources'/f'{name}-corresponding-source.tar.gz').is_file(),name
    assert (STAGE/'sources/MUMPS_5.7.3.tar.gz').is_file()
    # Raw build artifacts must not be hidden inside corresponding-source archives.
    import tarfile
    for path in (STAGE/'sources').glob('*.tar.gz'):
        with tarfile.open(path) as archive:
            for member in archive:
                assert not member.name.startswith('/') and '..' not in Path(member.name).parts,member.name
                if member.isfile():assert Path(member.name).suffix.lower() not in {'.exe','.dll','.lib','.obj','.a','.so'},member.name
    for case in ['electrostatic','magnetostatic','driven','eigenmode']:
        p=STAGE/'examples'/case
        config=json.loads((p/'config.json').read_text())
        assert (p/config['Model']['Mesh']).is_file(),case
    result=dict(scope='Exact payload inventory/hashes only; no redistribution or clean-host pass',files=len(actual)+1,bytes=sum(p.stat().st_size for p in actual.values())+(STAGE/'build-manifest.json').stat().st_size,binaries=sorted(binaries),status='pass')
    (STAGE.parent/(STAGE.name+'-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))

if __name__=='__main__': main()
