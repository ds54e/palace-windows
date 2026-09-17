#!/usr/bin/env python3
"""Archive a verified internal candidate; never publish or approve it."""
import hashlib
import json
from pathlib import Path
import zipfile
from verify_stage import ROOT, STAGE, main as verify


def main():
    verify()
    output=STAGE.parent/(STAGE.name+'-internal.zip')
    if output.exists(): raise RuntimeError('Archive exists; preserve previous candidate evidence')
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as archive:
        for path in sorted(STAGE.rglob('*')):
            if path.is_file(): archive.write(path,str(Path(STAGE.name)/path.relative_to(STAGE)))
    digest=hashlib.sha256(output.read_bytes()).hexdigest()
    output.with_suffix('.zip.sha256').write_text(f'{digest}  {output.name}\n')
    diagnostics=STAGE.parent/(STAGE.name+'-diagnostics.zip')
    with zipfile.ZipFile(diagnostics,'w',compression=zipfile.ZIP_DEFLATED) as archive:
        archive.write(ROOT/'.work/build/palace-native/palace.map','palace.map')
        archive.write(ROOT/'.work/build/metis-shared/libmetis/metis.map','metis.map')
        archive.writestr('README.txt','No PDB was produced by the validated Release recipe. This separate archive contains the actual linker map; it is not a substitute for full debug symbols.\n')
    result=dict(status='INTERNAL_VALIDATION_ONLY_NOT_APPROVED_FOR_REDISTRIBUTION',archive=output.name,sha256=digest,bytes=output.stat().st_size,diagnostics=dict(path=diagnostics.name,sha256=hashlib.sha256(diagnostics.read_bytes()).hexdigest(),bytes=diagnostics.stat().st_size),signature='unsigned',clean_host='not executed',redistribution='LEGAL_REVIEW_PENDING: LGPL/Intel combined-work determination only')
    (STAGE.parent/(STAGE.name+'-archive-manifest.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__': main()
