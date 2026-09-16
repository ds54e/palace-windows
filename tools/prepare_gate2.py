#!/usr/bin/env python3
"""Prepare exact Windows overlay sources; run prepare_gate1.py first (WSL developer tool)."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import tarfile
import zipfile
from prepare_gate1 import ROOT, WORK, download, run


def apply(tree, patches):
    if not patches:
        return
    args = [str(p) for p in patches]
    if subprocess.run(['git', '-C', str(tree), 'apply', '--reverse', '--check', *args],
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
        return
    run('git', '-C', tree, 'apply', '--check', *patches)
    run('git', '-C', tree, 'apply', *patches)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--sources-only', action='store_true', help='Verify/prepare sources without re-extracting the compiler')
    args = parser.parse_args()
    lock = json.loads((ROOT / 'deps/gate2-lock.json').read_text())
    for name, digest in lock['local_patch_sha256'].items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
            raise RuntimeError('Patch hash mismatch: ' + name)
    for source in lock['sources']:
        tree = WORK / 'sources' / source['name']
        if not (tree / '.git').exists():
            tree.mkdir(parents=True, exist_ok=True)
            run('git', '-C', tree, 'init', '-q')
            run('git', '-C', tree, 'fetch', '--depth', '1', source['url'], source['commit'])
            run('git', '-C', tree, 'checkout', '--detach', source['commit'])
        actual = subprocess.check_output(['git', '-C', str(tree), 'rev-parse', 'HEAD'], text=True).strip()
        if actual != source['commit']:
            raise RuntimeError('Source pin mismatch: ' + str(tree))
        if source['name'] == 'mfem':
            for patch in lock['mfem_upstream_patches']:
                apply(tree, [download(patch)])
        apply(tree, [ROOT / p for p in lock['local_patches'].get(source['name'], [])])
    if args.sources_only:
        print('Pinned overlay sources and patches verified/prepared.')
        return
    item = lock['compiler_supplement']
    archive = download(item)
    with zipfile.ZipFile(archive) as z:
        for name in z.namelist():
            if not name.endswith('.tar.zst'):
                continue
            temporary = WORK / 'downloads' / name
            temporary.write_bytes(z.read(name))
            destination = (WORK / 'deps/intel' if name.startswith('pkg-') else
                           WORK / 'gate2/package-info/dpcpp_impl_win-64')
            destination.mkdir(parents=True, exist_ok=True)
            process = subprocess.Popen(['zstd', '-d', '-c', str(temporary)], stdout=subprocess.PIPE)
            with tarfile.open(fileobj=process.stdout, mode='r|') as tar:
                tar.extractall(destination, filter='data')
            if process.wait():
                raise RuntimeError('Compiler extraction failed')
            temporary.unlink()
    print('Pinned Gate 2 inputs prepared; no build/deployment pass implied.')


if __name__ == '__main__':
    main()
