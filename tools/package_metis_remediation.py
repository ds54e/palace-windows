#!/usr/bin/env python3
"""Build and freeze a distinct internal METIS-remediated candidate."""
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OLD_STAGE = ROOT / '.work/package/palace-windows-1.0.0-review2'
OLD_ZIP = ROOT / '.work/package/palace-windows-1.0.0-review2-internal.zip'
STAGE = ROOT / '.work/package/palace-windows-1.0.0-metis-remediation-review1'
ZIP = STAGE.parent / (STAGE.name + '-internal.zip')
OLD_SHA = '6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(source, output, prefix):
    entries = subprocess.check_output(
        ['git', '-C', str(source), 'ls-files', '-s', '-z']).decode().split('\0')
    with output.open('wb') as raw, gzip.GzipFile(
            filename='', fileobj=raw, mode='wb', mtime=0) as compressed, \
            tarfile.open(fileobj=compressed, mode='w|') as archive:
        for item in sorted(filter(None, entries)):
            metadata, name = item.split('\t', 1)
            mode = metadata.split()[0]
            path = source / name
            if not path.is_file():
                continue
            info = tarfile.TarInfo(str(Path(prefix) / name))
            info.size = path.stat().st_size
            info.mode = 0o755 if mode == '100755' else 0o644
            info.mtime = 0
            with path.open('rb') as stream:
                archive.addfile(info, stream)


def matrix_markdown(matrix):
    lines = ['# Redistribution matrix — METIS-remediated candidate', '',
             f"**Status: {matrix['status']}.**", '',
             '| Component | Version/commit | Linkage | License | Status |',
             '|---|---|---|---|---|']
    for row in matrix['components']:
        clean = lambda value: str(value).replace('|', '\\|').replace('\n', ' ')
        lines.append('| ' + ' | '.join(clean(row[key]) for key in
                     ('component', 'exact_version_or_commit', 'linkage_mode', 'license', 'status')) + ' |')
    lines += ['', 'The JSON matrix is controlling and contains exact hashes, rights, notices, source obligations and evidence.']
    return '\n'.join(lines) + '\n'


def main():
    if sha(OLD_ZIP) != OLD_SHA:
        raise RuntimeError('Frozen review2 ZIP identity changed')
    if STAGE.exists() or ZIP.exists():
        raise RuntimeError('Distinct candidate already exists; preserve it')
    shutil.copytree(OLD_STAGE, STAGE)
    shutil.copy2(ROOT / '.work/build/palace-metis-remediation/palace.exe', STAGE / 'palace.exe')
    shutil.copy2(ROOT / '.work/install/metis-remediation/lib/metis.dll', STAGE / 'metis.dll')
    (STAGE / 'METIS_REPLACEMENT.txt').unlink(missing_ok=True)
    copies = {
        'README_METIS_REMEDIATED.txt': 'README.txt',
        'METIS_REMEDIATION.txt': 'METIS_REMEDIATION.txt',
        'RUNTIME_TERMS_METIS_REMEDIATED.txt': 'RUNTIME_TERMS.txt',
        'REDISTRIBUTION_REVIEW_METIS_REMEDIATED.md': 'REDISTRIBUTION_REVIEW.md',
    }
    for source, target in copies.items():
        shutil.copy2(ROOT / 'docs/packaging' / source, STAGE / target)

    reference = ROOT / '.work/sources/networkx-metis-reference'
    reference_files = {'NOTICE': 'NOTICE', 'LICENSE.txt': 'LICENSE.txt',
                       'src/LICENSE.txt': 'src-LICENSE.txt'}
    target = STAGE / 'licenses/metis-remediation'
    target.mkdir(parents=True, exist_ok=True)
    for source, name in reference_files.items():
        shutil.copy2(reference / source, target / name)
    snapshot(ROOT / '.work/sources/metis', STAGE / 'sources/metis-corresponding-source.tar.gz', 'metis')

    matrix_path = ROOT / 'docs/packaging/REDISTRIBUTION_MATRIX_METIS_REMEDIATED.json'
    matrix = json.loads(matrix_path.read_text())
    closure = json.loads((ROOT / '.work/legal-remediation/audit/runtime-final/closure.json').read_text(encoding='utf-8-sig'))
    matrix['binary_closure'] = closure['files']
    material = [p for p in sorted(STAGE.rglob('*')) if p.is_file() and
                (p.relative_to(STAGE).parts[0] in {'sources', 'licenses'} or
                 p.suffix.lower() in {'.exe', '.dll'})]
    matrix['package_fulfillment'] = {
        'status': 'MECHANICALLY_COMPLETE',
        'scope': 'Exact distinct internal payload; clean-host validation remains deferred',
        'payload_files': [{'path': p.relative_to(STAGE).as_posix(), 'sha256': sha(p)} for p in material]
    }
    matrix_path.write_text(json.dumps(matrix, indent=2) + '\n')
    (STAGE / 'REDISTRIBUTION_MATRIX.json').write_bytes(matrix_path.read_bytes())
    markdown = matrix_markdown(matrix)
    (ROOT / 'docs/packaging/REDISTRIBUTION_MATRIX_METIS_REMEDIATED.md').write_text(markdown)
    (STAGE / 'REDISTRIBUTION_MATRIX.md').write_text(markdown)

    old_manifest = json.loads((STAGE / 'build-manifest.json').read_text())
    manifest = {
        'status': 'INTERNAL_METIS_REMEDIATION_REVIEW_CANDIDATE',
        'clean_host': {'executed': False, 'passed': False, 'decision': 'deferred_by_owner'},
        'historical_review2_zip_sha256': OLD_SHA,
        'repository_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'palace_executable_sha256': sha(STAGE / 'palace.exe'),
        'metis_dll_sha256': sha(STAGE / 'metis.dll'),
        'comparison': json.loads((ROOT / '.work/legal-remediation/final-comparison/comparison.json').read_text()),
        'redistribution_matrix_sha256': sha(STAGE / 'REDISTRIBUTION_MATRIX.json'),
        'predecessor_manifest_sha256': sha(OLD_STAGE / 'build-manifest.json'),
        'files': []
    }
    manifest['files'] = [{'path': p.relative_to(STAGE).as_posix(), 'size': p.stat().st_size, 'sha256': sha(p)}
                         for p in sorted(STAGE.rglob('*')) if p.is_file() and p.name != 'build-manifest.json']
    (STAGE / 'build-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    with zipfile.ZipFile(ZIP, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sorted(STAGE.rglob('*')):
            if not path.is_file():
                continue
            info = zipfile.ZipInfo(path.relative_to(STAGE).as_posix(), (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    if sha(OLD_ZIP) != OLD_SHA:
        raise RuntimeError('Frozen review2 ZIP changed during packaging')
    print(json.dumps({'stage': str(STAGE), 'files': len(manifest['files']) + 1,
                      'zip': str(ZIP), 'zip_sha256': sha(ZIP)}, indent=2))


if __name__ == '__main__':
    main()
