#!/usr/bin/env python3
"""Create fixed, small Gate 2 cases from the pinned Palace examples (developer tool)."""
import hashlib
import json
from pathlib import Path
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / '.work/sources/palace/examples'
DEST = ROOT / '.work/gate2/palace-smoke'


def read_jsonc(path):
    text = path.read_text()
    # Preserve quoted strings while removing upstream JSONC comments.
    token = re.compile(r'("(?:\\.|[^"\\])*")|//[^\n]*|/\*[\s\S]*?\*/')
    text = token.sub(lambda m: m[1] if m[1] is not None else '', text)
    text = re.sub(r',\s*([}\]])', r'\1', text)
    return json.loads(text)


def main():
    entries = []
    for name, original in [('electrostatic', 'spheres/spheres.json'),
                           ('magnetostatic', 'rings/rings.json'),
                           ('driven', 'coaxial/coaxial_matched.json'),
                           ('eigenmode', 'cylinder/cavity_pec.json')]:
        source = SOURCE / original
        config = read_jsonc(source)
        config['Problem']['Output'] = 'output'
        config['Problem']['OutputFormats'] = {'Paraview': True, 'GridFunction': True}
        config['Domains'].get('Postprocessing', {}).pop('Probe', None)
        solver = config['Solver']
        solver['Order'] = 1
        if name != 'magnetostatic':
            solver['Linear'].update(Type='MUMPS', ColumnOrdering='METIS', MGMaxLevels=1)
        if name == 'driven':
            config['Problem']['Type'] = 'Driven'
            solver.pop('Transient')
            solver['Driven'] = {'Samples': [{'Type': 'Linear', 'MinFreq': 5.0, 'MaxFreq': 5.0, 'FreqStep': 1.0}], 'Save': [5.0]}
            solver['Linear']['KSPType'] = 'GMRES'
            for port in config['Boundaries']['LumpedPort']:
                port['Excitation'] = port['Index']
        if name == 'eigenmode':
            solver['Eigenmode'].update(N=2, Save=2, Type='ARPACK', MaxIts=1000)
            config['Domains']['Materials'][0]['LossTan'] = 0.0
        directory = DEST / name
        (directory / 'mesh').mkdir(parents=True, exist_ok=True)
        mesh = source.parent / config['Model']['Mesh']
        shutil.copyfile(mesh, directory / config['Model']['Mesh'])
        target = directory / 'config.json'
        target.write_text(json.dumps(config, indent=2) + '\n')
        entries.append({'case': name, 'upstream_config': original,
                        'upstream_config_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                        'mesh_sha256': hashlib.sha256(mesh.read_bytes()).hexdigest(),
                        'config_sha256': hashlib.sha256(target.read_bytes()).hexdigest()})
    (DEST / 'inputs.json').write_text(json.dumps({'scope': 'Gate 2 functionality smoke, not numerical equivalence', 'cases': entries}, indent=2) + '\n')
    print('Prepared four fixed smoke inputs; original examples remain unchanged.')


if __name__ == '__main__':
    main()
