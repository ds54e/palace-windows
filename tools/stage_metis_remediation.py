#!/usr/bin/env python3
"""Create a distinct developer-host fixture for the remediated METIS DLL."""
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
FROZEN = ROOT / '.work/package/palace-windows-1.0.0-review2-internal.zip'
BASE = ROOT / '.work/package/palace-windows-1.0.0-review2'
METIS = ROOT / '.work/install/metis-remediation/lib/metis.dll'
PALACE = ROOT / '.work/build/palace-metis-remediation/palace.exe'
OUTPUT = ROOT / '.work/legal-remediation/candidate-app-local'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    expected = '6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2'
    if sha(FROZEN) != expected:
        raise RuntimeError('Frozen review2 ZIP identity changed')
    if OUTPUT.exists():
        raise RuntimeError('Choose a new remediation fixture path')
    OUTPUT.mkdir(parents=True)
    original = json.loads((BASE / 'build-manifest.json').read_text())
    binaries = [item['path'] for item in original['files']
                if Path(item['path']).parent == Path('.') and
                Path(item['path']).suffix.lower() in {'.exe', '.dll'} and
                item['path'].lower() != 'palace-sparams.exe']
    for name in binaries:
        source = (METIS if name.lower() == 'metis.dll' else
                  PALACE if name.lower() == 'palace.exe' else BASE / name)
        shutil.copy2(source, OUTPUT / name)
    shutil.copytree(BASE / 'examples', OUTPUT / 'examples')
    files = [dict(path=p.relative_to(OUTPUT).as_posix(), size=p.stat().st_size,
                  sha256=sha(p)) for p in sorted(OUTPUT.rglob('*')) if p.is_file()]
    manifest = dict(
        status='INTERNAL_METIS_REMEDIATION_VALIDATION_ONLY',
        clean_host='deferred and unexecuted',
        source_review2_zip_sha256=expected,
        palace_executable_sha256=sha(OUTPUT / 'palace.exe'),
        remediated_metis_sha256=sha(OUTPUT / 'metis.dll'),
        files=files)
    (OUTPUT / 'build-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(OUTPUT)


if __name__ == '__main__':
    main()
