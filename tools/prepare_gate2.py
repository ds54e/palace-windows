#!/usr/bin/env python3
"""Prepare exact Windows overlay sources; run prepare_gate1.py first (WSL developer tool)."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import tarfile
import zipfile
import re
import shutil
import tempfile
from prepare_gate1 import ROOT, WORK, download, run


def apply(tree, patches):
    """Verify/apply ordered overlapping patches without modifying a partial tree."""
    if not patches:
        return
    patches = [Path(p).resolve() for p in patches]
    touched = set()
    for patch in patches:
        for name in re.findall(r"^(?:--- a/|\+\+\+ b/)([^\t\n]+)", patch.read_text(), re.M):
            path = Path(name)
            if path.is_absolute() or '..' in path.parts:
                raise RuntimeError('Unsafe patch path: ' + name)
            touched.add(path)
    with tempfile.TemporaryDirectory(prefix='patch-check-', dir=WORK) as temporary:
        trial = Path(temporary)
        run('git', '-C', trial, 'init', '-q')
        def reset_trial():
            for name in touched:
                target = trial / name
                target.parent.mkdir(parents=True, exist_ok=True)
                if (tree / name).is_file():
                    shutil.copy2(tree / name, target)
                elif target.exists():
                    target.unlink()
        reset_trial()
        already_applied = True
        for patch in reversed(patches):
            result = subprocess.run(['git', '-C', str(trial), 'apply', '--reverse', str(patch)],
                                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if result.returncode:
                already_applied = False
                break
        if already_applied:
            return
        reset_trial()
        for patch in patches:
            run('git', '-C', trial, 'apply', patch)
        # Copy only after the entire ordered patch set succeeds in isolation.
        for name in touched:
            target = tree / name
            if (trial / name).is_file():
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(trial / name, target)
            elif target.exists():
                target.unlink()


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
