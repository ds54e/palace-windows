#!/usr/bin/env python3
"""Prepare or verify the locked, non-installed Linux comparison environment."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / '.work/linux-reference'


def run(*args, **kwargs):
    subprocess.run([str(a) for a in args], check=True, **kwargs)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify', action='store_true', help='Read-only identity checks; do not extract during a build')
    args = parser.parse_args()
    lock = json.loads((ROOT / 'deps/linux-reference-lock.json').read_text())
    gate2 = json.loads((ROOT / 'deps/gate2-lock.json').read_text())
    gate1 = json.loads((ROOT / 'deps/gate1-lock.json').read_text())
    sysroot = BASE / 'sysroot'
    for package in lock['packages']:
        archive = ROOT / '.work/downloads/linux-reference' / package['filename']
        if not archive.exists() and not args.verify:
            archive.parent.mkdir(parents=True, exist_ok=True)
            with urllib.request.urlopen(package['url']) as response:
                archive.write_bytes(response.read())
        if not archive.exists() or digest(archive) != package['sha256']:
            raise RuntimeError('Package identity mismatch: ' + str(archive))
        if not args.verify:
            verification = subprocess.check_output(['rpm', '-K', str(archive)], text=True)
            if 'digests signatures OK' not in verification:
                raise RuntimeError('RPM signature not verified: ' + verification)
            sysroot.mkdir(parents=True, exist_ok=True)
            process = subprocess.Popen(['rpm2cpio', str(archive)], stdout=subprocess.PIPE)
            run('cpio', '-idm', '--quiet', '--no-absolute-filenames', '--no-preserve-owner', stdin=process.stdout, cwd=sysroot)
            process.stdout.close()
            if process.wait():
                raise RuntimeError('RPM payload extraction failed')
    if not args.verify:
        script = sysroot / 'usr/lib/gcc/x86_64-redhat-linux/11/libquadmath.so'
        script.write_text(script.read_text().replace('/usr/lib64/', str(sysroot / 'usr/lib64') + '/'))
        bin_dir = BASE / 'bin'; bin_dir.mkdir(parents=True, exist_ok=True)
        wrapper = bin_dir / 'gfortran-reference'
        wrapper.write_text('''#!/usr/bin/env bash
set -e
root=$(cd "$(dirname "$0")/../../.." && pwd)
sysroot="$root/.work/linux-reference/sysroot"
exec "$sysroot/usr/bin/gfortran" -B/usr/libexec/gcc/x86_64-redhat-linux/11/ -B/usr/lib/gcc/x86_64-redhat-linux/11/ -L"$sysroot/usr/lib/gcc/x86_64-redhat-linux/11" "$@"
''')
        wrapper.chmod(0o755)
    patch = ROOT / lock['palace_reference_patch']['path']
    if digest(patch) != lock['palace_reference_patch']['sha256']:
        raise RuntimeError('Reference patch mismatch')
    for name, identity in lock['reference_sources'].items():
        target = BASE / 'sources' / name
        if not (target / '.git').exists() and not args.verify:
            if name == 'scalapack':
                target.mkdir(parents=True, exist_ok=True)
                run('git', '-C', target, 'init', '-q')
                run('git', '-C', target, 'fetch', '--depth', '1', lock['additional_source']['url'], identity['commit'])
                run('git', '-C', target, 'checkout', '--detach', identity['commit'])
            else:
                run('git', 'clone', '--shared', ROOT / '.work/sources' / name, target)
                if name == 'palace':
                    for item in gate2['local_patches']['palace']:
                        run('git', '-C', target, 'apply', ROOT / item)
                    run('git', '-C', target, 'apply', patch)
                elif name == 'arpack-ng':
                    for suffix in ('build', 'zdotc', 'pzneupd', 'second'):
                        run('git', '-C', target, 'apply', ROOT / f'.work/sources/palace/extern/patch/arpack-ng/patch_{suffix}.diff')
        actual = subprocess.check_output(['git', '-C', str(target), 'rev-parse', 'HEAD'], text=True).strip()
        diff = subprocess.check_output(['git', '-C', str(target), 'diff'])
        if actual != identity['commit'] or hashlib.sha256(diff).hexdigest() != identity['diff_sha256']:
            raise RuntimeError('Reference source identity mismatch: ' + name)
    print('Locked Linux comparison inputs verified; no system installation performed.')


if __name__ == '__main__':
    main()
