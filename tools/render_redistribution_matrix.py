#!/usr/bin/env python3
"""Render the sole current redistribution matrix; never infer clearance."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    base = ROOT / 'docs/packaging'
    record = json.loads((base / 'REDISTRIBUTION_MATRIX.json').read_text())
    lines = ['# Exact redistribution matrix', '', record['scope'], '',
             '**Status: ' + record['status'] + '.** Component permission, package fulfillment and combined-work compatibility are distinct. Full artifact identities and evidence are in REDISTRIBUTION_MATRIX.json.', '',
             '| Component | Exact version/commit | Artifact/hash | Linkage mode | License | Redistribution right | Required notices | Source/relink obligation | Status/evidence |',
             '|---|---|---|---|---|---|---|---|---|']
    for row in record['components']:
        if row['status'].lower() == 'assumed':
            raise ValueError('Assumed permission is not an acceptable matrix status')
        artifacts = '<br>'.join(Path(a['path']).name + ' / ' + a['sha256'] for a in row['artifacts'])
        values = [row['component'], row['exact_version_or_commit'], artifacts,
                  row['linkage_mode'], row['license'], row['redistribution_right'],
                  row['required_notices'], row['source_or_relink_obligation'],
                  row['status'] + '; ' + '; '.join(row['evidence'])]
        if not all(values):
            raise ValueError('Incomplete matrix row: ' + row['component'])
        lines.append('| ' + ' | '.join(v.replace('|', '/') for v in values) + ' |')
    (base / 'REDISTRIBUTION_MATRIX.md').write_text('\n'.join(lines) + '\n')

if __name__ == '__main__':
    main()
