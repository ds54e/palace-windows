#!/usr/bin/env python3
"""Verify exact package bytes, selected members and linked Intel identities."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import zipfile

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.work/redistribution'

def digest(stream):
    h=hashlib.sha256()
    while data:=stream.read(1024*1024): h.update(data)
    return h.hexdigest()
def sha(path):
    with path.open('rb') as f:return digest(f)

def main():
    OUT.mkdir(exist_ok=True)
    lock=json.loads((ROOT/'deps/gate1-lock.json').read_text())
    wanted={
      'compiler_shared':{'Library/lib/libircmt.lib','Library/lib/libmmd.lib','Library/lib/svml_dispmd.lib'},
      'ifx_impl_win-64':{'Library/lib/libifcoremd.lib'},
      'intel-cmplr-lib-rt':{'Library/bin/libircmd.dll','Library/lib/libircmd.lib','Library/lib/libircdisp.lib','Library/bin/libmmd.dll','Library/bin/svml_dispmd.dll'},
      'intel-fortran-rt':{'Library/bin/libifcoremd.dll','share/doc/compiler/fredist.txt','share/doc/compiler/licensing/fortran/LICENSE.rtf','share/doc/compiler/licensing/fortran/third-party-programs.txt'},
      'intel-cmplr-lic-rt':{'licensing/compiler/Intel Developer Tools EULA.rtf'}}
    records=[]
    for item in lock['packages']:
        name=item['name']; numerical=item['filename'].endswith('.nupkg')
        if name not in wanted and not numerical:continue
        archive=ROOT/'.work/downloads'/item['filename']
        assert sha(archive)==item['sha256'],archive
        record=dict(package=item['filename'],version=item['version'],url=item['url'],sha256=item['sha256'],members=[])
        with zipfile.ZipFile(archive) as z:
            if numerical:
                selected={'mkl_core.lib','mkl_intel_lp64.lib','mkl_sequential.lib','mkl_scalapack_lp64.lib','mkl_blacs_msmpi_lp64.lib','license.txt'}
                for member in z.namelist():
                    if Path(member).name not in selected:continue
                    with z.open(member) as f: value=digest(f)
                    local=ROOT/'.work/deps'/('mkl-cluster' if '.cluster.' in name else 'mkl')/member
                    assert sha(local)==value,local
                    record['members'].append(dict(member=member,sha256=value,local=str(local.relative_to(ROOT)),verified=True))
            else:
                compressed=OUT/'package-scan.tar.zst'
                entry=next(n for n in z.namelist() if n.startswith('pkg-') and n.endswith('.tar.zst'))
                with z.open(entry) as f, compressed.open('wb') as g:shutil.copyfileobj(f,g)
                proc=subprocess.Popen(['zstd','-q','-d','-c',str(compressed)],stdout=subprocess.PIPE)
                found=set()
                with tarfile.open(fileobj=proc.stdout,mode='r|') as t:
                    for m in t:
                        member=m.name.removeprefix('./')
                        if member not in wanted[name]:continue
                        value=digest(t.extractfile(m));local=ROOT/'.work/deps/intel'/member
                        assert sha(local)==value,local
                        record['members'].append(dict(member=member,sha256=value,local=str(local.relative_to(ROOT)),verified=True));found.add(member)
                proc.stdout.close();assert proc.wait()==0
                compressed.unlink();assert found==wanted[name],(name,wanted[name]-found)
        records.append(record)
    maps={}
    for name,path in [('prior_candidate',OUT/'pre-link/palace.map'),('working_candidate',ROOT/'.work/build/palace-native/palace.map')]:
        libs={}
        for lib,obj in re.findall(r'\b([A-Za-z_][A-Za-z0-9_.-]*):([^\s]+\.(?:obj|dll))',path.read_text()):
            if lib.startswith(('libirc','libif','libmm','svml','mkl_')):libs.setdefault(lib,set()).add(obj)
        maps[name]=dict(path=str(path.relative_to(ROOT)),sha256=sha(path),objects={k:sorted(v) for k,v in sorted(libs.items())})
    fredist=ROOT/'.work/deps/intel/share/doc/compiler/fredist.txt'
    report=dict(packages=records,maps=maps,fredist_sha256=sha(fredist),
      eula_sha256=sha(ROOT/'.work/deps/intel/licensing/compiler/Intel Developer Tools EULA.rtf'),
      license_basis='Exact accompanying August 2024 EULA 1.I and 2.1.D; fredist names are required, not generic static-deployment guidance. oneMKL uses accompanying October 2022 Simplified Software License.',
      libircmt_coverage='Not named in the exact 2025.3 fredist; no affirmative exact-file grant established. Prior candidate is not cleared.',
      listed_alternative='libircmd.dll, libircmd.lib and libircdisp.lib are explicitly named; working candidate must show zero libircmt incorporated objects and pass ABI/numerical tests.',
      shipped_vs_incorporated='DLLs ship as separate files. .lib members with .obj map entries are incorporated; .dll map entries are import records, not static implementations.')
    (OUT/'intel-package-audit.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Verified package/member hashes and Intel linkage identities:',len(records),'packages')

if __name__=='__main__':main()
