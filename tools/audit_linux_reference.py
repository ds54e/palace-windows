#!/usr/bin/env python3
"""Run after the Linux build, in scripts/linux-reference-env.sh environment."""
import ctypes
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'.work/linux-reference'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def run(*args): return subprocess.check_output(list(map(str,args)),text=True,stderr=subprocess.STDOUT).strip()

def main():
    exe=BASE/'build/palace/palace-x86_64.bin'
    records=[]
    for archive in sorted((BASE/'install/lib').glob('*.a')):
        symbols=run('nm','-g','--defined-only',archive)
        assert not re.search(r'\b(?:ParMETIS_|libparmetis__)',symbols),archive
        records.append(dict(path=str(archive.relative_to(ROOT)),sha256=sha(archive)))
    linkmap=BASE/'build/palace/palace.map'
    assert not re.search(r'libparmetis\.(?:a|so)',linkmap.read_text(),re.I)
    closure=run('ldd',exe)
    assert 'not found' not in closure and 'libparmetis' not in closure.lower(),closure
    blas=BASE/'sysroot/usr/lib64/libopenblas.so.0'
    library=ctypes.CDLL(str(blas))
    library.openblas_get_config.restype=ctypes.c_char_p
    config=library.openblas_get_config().decode()
    assert 'USE64BITINT' not in config,config
    assert library.openblas_get_num_threads()==1
    sources=[]
    for folder in [ROOT/'.work/sources',BASE/'sources']:
        for name in ['palace','mfem','metis','hypre','mumps','arpack-ng','libCEED','json','json-schema-validator','fmt','scn','eigen','fast_float','scalapack']:
            p=folder/name
            if not (p/'.git').exists(): continue
            diff=subprocess.check_output(['git','-C',str(p),'diff','--binary'])
            sources.append(dict(path=str(p.relative_to(ROOT)),commit=run('git','-C',p,'rev-parse','HEAD'),diff_sha256=hashlib.sha256(diff).hexdigest()))
    report=dict(scope='Linux one-rank numerical reference; no Windows deployment claim',
        executable=dict(path=str(exe.relative_to(ROOT)),sha256=sha(exe)),
        compiler=dict(c=run('gcc','--version').splitlines()[0],cxx=run('g++','--version').splitlines()[0],fortran=run(BASE/'bin/gfortran-reference','--version').splitlines()[0]),
        mpi=run('ompi_info','--version').splitlines()[0],blas=dict(config=config,sha256=sha(blas),threads=1),
        abi='Linux x64 LP64 host; 32-bit Fortran/MPI/MUMPS/Hypre/METIS/BLAS numerical integers; complex<double> binary64 pairs',
        ordering='MUMPS PORD/METIS connection tests; explicit METIS for electrostatic/driven/eigenmode, AMS for magnetostatic',
        parmetis='No implementation symbols in installed archives or artifact in Palace link map/runtime closure',
        archives=records,sources=sources,linkmap_sha256=sha(linkmap),ldd=closure)
    (ROOT/'.work/gate3/linux-identity.json').write_text(json.dumps(report,indent=2)+'\n')
    print(f'Linux identity recorded; {len(records)} archives inspected; no ParMETIS artifact.')

if __name__=='__main__': main()
