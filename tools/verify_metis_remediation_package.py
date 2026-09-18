#!/usr/bin/env python3
"""Verify the frozen internal METIS-remediated review artifact."""
import hashlib
import json
from pathlib import Path
import tarfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / '.work/package/palace-windows-1.0.0-metis-remediation-review1'
ZIP = STAGE.parent / (STAGE.name + '-internal.zip')
OLD_ZIP = ROOT / '.work/package/palace-windows-1.0.0-review2-internal.zip'
OLD_SHA = '6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    manifest = json.loads((STAGE / 'build-manifest.json').read_text())
    assert manifest['clean_host'] == {'executed': False, 'passed': False, 'decision': 'deferred_by_owner'}
    assert sha(OLD_ZIP) == OLD_SHA == manifest['historical_review2_zip_sha256']
    expected = {item['path']: item for item in manifest['files']}
    actual = {p.relative_to(STAGE).as_posix(): p for p in STAGE.rglob('*')
              if p.is_file() and p.name != 'build-manifest.json'}
    assert expected.keys() == actual.keys(), (expected.keys() - actual.keys(), actual.keys() - expected.keys())
    for name, path in actual.items():
        assert path.stat().st_size == expected[name]['size'], name
        assert sha(path) == expected[name]['sha256'], name
    assert sha(STAGE / 'palace.exe') == '0364deb1a32b0b3f94d13c4aff94a431f5f2fad91856afd389501cce23ff4568'
    assert sha(STAGE / 'metis.dll') == '1a6af7bace9954e31f432133e16d4d112489e7ba897329f16ceed4550732ef8a'
    assert not (STAGE / 'METIS_REPLACEMENT.txt').exists()

    matrix = json.loads((STAGE / 'REDISTRIBUTION_MATRIX.json').read_text())
    assert matrix['status'] == 'COMPONENT_REMEDIATION_REVIEW_COMPLETE'
    assert matrix['legal_review']['status'] == 'RESOLVED_BY_COMPONENT_REPLACEMENT'
    assert matrix['package_fulfillment']['status'] == 'MECHANICALLY_COMPLETE'
    assert all(row['status'] == 'COMPONENT_REVIEW_COMPLETE' for row in matrix['components'])
    assert sha(STAGE / 'REDISTRIBUTION_MATRIX.json') == manifest['redistribution_matrix_sha256']
    for item in matrix['binary_closure']:
        assert sha(STAGE / item['name']) == item['sha256'], item['name']

    reference_hashes = {
        'NOTICE': 'e00106accaf7e4dbd86e65489abd36106a62687daffda73c6d62551dc3b0c4c8',
        'LICENSE.txt': '6f2682b274d6fbf941ef89f13e09822f6aba21cbf3a560f19a0b6f23329249f4',
        'src-LICENSE.txt': '64ab947d7b289ad76e935adff51b31e4ac160df7dfad24480dbaa452e39bbe79'
    }
    for name, digest in reference_hashes.items():
        assert sha(STAGE / 'licenses/metis-remediation' / name) == digest, name

    source = STAGE / 'sources/metis-corresponding-source.tar.gz'
    with tarfile.open(source) as archive:
        members = {item.name: item for item in archive}
        for required in ['metis/GKlib/sort.cc', 'metis/libmetis/gklib_sort.cc',
                         'metis/GKlib/sort.c', 'metis/GKlib/getopt.c',
                         'metis/GKlib/gkregex.c']:
            assert required in members, required
        for item in members.values():
            assert not item.name.startswith('/') and '..' not in Path(item.name).parts
            if item.isfile():
                assert Path(item.name).suffix.lower() not in {'.exe', '.dll', '.lib', '.obj', '.a', '.so'}
    assert (STAGE / 'licenses/metis/GKlib/LGPL-2.1.txt').is_file()

    forbidden = [name for name in actual if 'parmetis' in Path(name).name.lower() or
                 Path(name).suffix.lower() in {'.lib', '.obj', '.a', '.so'}]
    assert not forbidden, forbidden
    with zipfile.ZipFile(ZIP) as archive:
        assert archive.testzip() is None
        zip_files = {item.filename: item for item in archive.infolist() if not item.is_dir()}
        staged = {p.relative_to(STAGE).as_posix(): p for p in STAGE.rglob('*') if p.is_file()}
        assert zip_files.keys() == staged.keys()
        for name, path in staged.items():
            assert hashlib.sha256(archive.read(name)).hexdigest() == sha(path), name
    result = {
        'status': 'pass',
        'scope': 'Exact inventory/source/ZIP verification; independent clean-host validation remains deferred',
        'stage_files': len(actual) + 1,
        'stage_bytes': sum(p.stat().st_size for p in actual.values()) + (STAGE / 'build-manifest.json').stat().st_size,
        'zip_sha256': sha(ZIP),
        'manifest_sha256': sha(STAGE / 'build-manifest.json'),
        'matrix_sha256': sha(STAGE / 'REDISTRIBUTION_MATRIX.json'),
        'historical_review2_unchanged': True
    }
    output = STAGE.parent / (STAGE.name + '-verification.json')
    output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
