#!/usr/bin/env python3
"""Fetch hash-pinned Gate 1 packages into .work; never run a system installer.

Run from WSL with Python 3.12+, Git and zstd. This is a developer tool, not
an end-user runtime dependency. Existing modified source trees are preserved.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / '.work'


def run(*args):
    subprocess.run([str(a) for a in args], check=True)


def download(item):
    path = WORK / 'downloads' / item['filename']
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        temporary = path.with_suffix(path.suffix + '.partial')
        urllib.request.urlretrieve(item['url'], temporary)
        if hashlib.sha256(temporary.read_bytes()).hexdigest() != item['sha256']:
            raise RuntimeError(f'Hash mismatch: {temporary}')
        temporary.replace(path)
    if hashlib.sha256(path.read_bytes()).hexdigest() != item['sha256']:
        raise RuntimeError(f'Hash mismatch: {path}')
    return path


def unzip(archive, destination):
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        for name in z.namelist():
            target = (destination / name).resolve()
            if not target.is_relative_to(destination.resolve()):
                raise RuntimeError(f'Unsafe ZIP member: {name}')
        z.extractall(destination)


def main():
    lock = json.loads((ROOT / 'deps/gate1-lock.json').read_text())
    intel = WORK / 'deps/intel'
    intel.mkdir(parents=True, exist_ok=True)
    for item in lock['packages']:
        archive = download(item)
        if archive.suffix == '.nupkg':
            destination = WORK / 'deps' / ('mkl-cluster' if '.cluster.' in item['name'] else 'mkl')
            unzip(archive, destination)
        else:
            with zipfile.ZipFile(archive) as z:
                for name in z.namelist():
                    if not name.endswith('.tar.zst'):
                        continue
                    temporary = WORK / 'gate1/package.tar'
                    temporary.parent.mkdir(parents=True, exist_ok=True)
                    with temporary.open('wb') as output:
                        subprocess.run(['zstd', '-d', '-c'], input=z.read(name), stdout=output, check=True)
                    destination = intel if name.startswith('pkg-') else WORK / 'gate1/package-info' / item['name']
                    destination.mkdir(parents=True, exist_ok=True)
                    with tarfile.open(temporary) as t:
                        t.extractall(destination, filter='data')
                    temporary.unlink()
        print(f'Verified and extracted {item["filename"]}', flush=True)

    palace = WORK / 'sources/palace'
    actual = subprocess.check_output(['git', '-C', str(palace), 'rev-parse', 'HEAD'], text=True).strip()
    if actual != lock['palace_commit']:
        raise RuntimeError('Palace source does not match lock')
    for source in lock['sources']:
        path = WORK / 'sources' / source['name']
        if path.exists():
            actual = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()
            if actual != source['commit']:
                raise RuntimeError(f'Source pin mismatch: {path}')
        else:
            run('git', 'clone', '--filter=blob:none', '--no-checkout', source['repository'], path)
            run('git', '-C', path, 'checkout', '--detach', source['commit'])
        patches = [palace / p for p in source['palace_patches']]
        patches += [ROOT / p for p in source.get('local_patches', [])]
        for name, expected in source.get('patch_hashes', {}).items():
            file = ROOT / name if name.startswith('patches/') else palace / name
            if hashlib.sha256(file.read_bytes()).hexdigest() != expected:
                raise RuntimeError(f'Patch hash mismatch: {file}')
        already = subprocess.run(['git', '-C', str(path), 'apply', '--reverse', '--check', *map(str, patches)],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
        if not already:
            run('git', '-C', path, 'apply', '--check', *patches)
            run('git', '-C', path, 'apply', *patches)
    archive = download(lock['mumps_source'])
    if not (WORK / 'sources/MUMPS_5.7.3').exists():
        with tarfile.open(archive) as t:
            t.extractall(WORK / 'sources', filter='data')
    print('Gate 1 inputs prepared. This is not a build or test result.')


if __name__ == '__main__':
    main()
