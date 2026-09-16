#!/usr/bin/env python3
"""Freeze identical Gate 3 inputs; does not inspect numerical results."""
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / '.work/gate3'
CASES = ('electrostatic', 'magnetostatic', 'driven', 'eigenmode')


def main():
    records = []
    for case in CASES:
        source = ROOT / '.work/gate2/palace-smoke' / case
        config = json.loads((source / 'config.json').read_text())
        config['Solver']['Backend'] = '/cpu/self/opt/blocked'
        if case == 'driven':
            config['Solver']['Driven']['Samples'] = [dict(Type='Linear', MinFreq=4.0, MaxFreq=6.0, FreqStep=1.0)]
            config['Solver']['Driven']['Save'] = [4.0, 5.0, 6.0]
        data = (json.dumps(config, indent=2) + '\n').encode()
        mesh = source / config['Model']['Mesh']
        for platform in ('windows', 'linux'):
            dest = BASE / platform / case
            (dest / 'mesh').mkdir(parents=True, exist_ok=True)
            (dest / 'config.json').write_bytes(data)
            shutil.copyfile(mesh, dest / config['Model']['Mesh'])
        records.append(dict(case=case, configuration_sha256=hashlib.sha256(data).hexdigest(),
                            mesh=config['Model']['Mesh'], mesh_sha256=hashlib.sha256(mesh.read_bytes()).hexdigest(),
                            solver=config['Solver']))
    report = dict(scope='Input identities, before Linux results', acceptance_sha256=hashlib.sha256(
        (ROOT / 'docs/GATE3_ACCEPTANCE.json').read_bytes()).hexdigest(), cases=records)
    (BASE / 'inputs.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Identical Windows/Linux meshes and configurations prepared.')


if __name__ == '__main__':
    main()
