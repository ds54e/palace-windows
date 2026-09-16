#!/usr/bin/env python3
"""Assess only the predeclared Gate 3 scalar/matrix criteria."""
import cmath
import csv
import hashlib
import json
import math
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from check_windows_smoke import check_vtu

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / '.work/gate3'
RULES = json.loads((ROOT / 'docs/GATE3_ACCEPTANCE.json').read_text())
CHECKS = []


def check(name, left, right, absolute, relative):
    error = abs(left - right)
    limit = absolute + relative * max(abs(left), abs(right))
    passed = math.isfinite(error) and error <= limit
    encode = lambda value: dict(real=value.real, imag=value.imag) if isinstance(value, complex) else value
    CHECKS.append(dict(name=name, left=encode(left), right=encode(right),
                       absolute_error=error, allowed_error=limit, passed=passed))


def table(path):
    with path.open(encoding='utf-8-sig', newline='') as stream:
        rows = list(csv.reader(stream))
    labels = [s.strip() for s in rows[0]]
    assert len(labels) == len(set(labels)), path
    values = [[float(s) for s in row] for row in rows[1:]]
    assert values and all(len(row) == len(labels) for row in values), path
    return labels, values


def matrix(path, symbol):
    labels, rows = table(path)
    columns = [int(re.fullmatch(rf'{symbol}\[i\]\[(\d+)\] \([FH]\)', v)[1]) for v in labels[1:]]
    values = {int(row[0]): dict(zip(columns, row[1:])) for row in rows}
    assert len(values) == len(rows) and set(values) == set(columns), path
    assert all(math.isfinite(v) for row in values.values() for v in row.values()), path
    return values


def compare_matrix(case, filename, symbol):
    rule = RULES[case]
    matrices = [matrix(BASE / platform / case / 'output' / filename, symbol) for platform in ('windows', 'linux')]
    w, l = matrices
    assert w.keys() == l.keys()
    ids = sorted(w); n = len(ids)
    for i in ids:
        for j in ids:
            check(f'{case}[{i},{j}]', w[i][j], l[i][j], rule['absolute'], rule['relative'])
    vectors = [[int(i == j) for i in range(n)] for j in range(n)] + [[1] * n, [(-1)**i for i in range(n)]]
    for label, function in [('trace', lambda a: sum(a[i][i] for i in ids)),
                            ('frobenius', lambda a: math.sqrt(sum(a[i][j]**2 for i in ids for j in ids)))]:
        check(f'{case}/{label}', function(w), function(l), n * rule['absolute'], rule['relative'])
    for index, v in enumerate(vectors):
        energy = lambda a: sum(v[i] * a[ii][jj] * v[j] for i, ii in enumerate(ids) for j, jj in enumerate(ids))
        assert energy(w) > 0 and energy(l) > 0, f'{case}: non-positive quadratic energy'
        check(f'{case}/quadratic-{index}', energy(w), energy(l), sum(abs(x) for x in v)**2 * rule['absolute'], rule['relative'])
    for platform, a in zip(('windows', 'linux'), matrices):
        for i in ids:
            assert a[i][i] > 0
            for j in ids:
                check(f'{case}/{platform}/reciprocity-{i}-{j}', a[i][j], a[j][i], rule['absolute'], rule['relative'])


def scattering(platform):
    labels, rows = table(BASE / platform / 'driven/output/port-S.csv')
    result = {}
    for row in rows:
        frequency = row[0]
        assert frequency not in result
        pairs = {}
        for col, label in enumerate(labels):
            match = re.fullmatch(r'\|S\[(\d+)\]\[(\d+)\]\| \(dB\)', label)
            if match:
                i, j = map(int, match.groups())
                phase = labels.index(f'arg(S[{i}][{j}]) (deg.)')
                pairs[i, j] = cmath.rect(10**(row[col] / 20), math.radians(row[phase]))
        assert set(pairs) == {(1, 1), (1, 2), (2, 1), (2, 2)}, 'Incomplete two-port S matrix'
        result[frequency] = pairs
    return result


def structural(platform, case):
    folder = BASE / platform / case / 'output'
    vtk = list(folder.rglob('*.vtu'))
    assert vtk, (platform, case, 'missing VTU')
    names = set()
    for path in vtk:
        names.update(check_vtu(path))
    for path in [*folder.rglob('*.pvd'), *folder.rglob('*.pvtu')]:
        for node in ET.parse(path).iter():
            target = node.get('file') or node.get('Source')
            if target:
                assert (path.parent / target).is_file(), (path, target)
    for path in folder.glob('*.csv'):
        labels, rows = table(path)
        for row in rows:
            for label, value in zip(labels, row):
                if label == 'Q' and math.isinf(value) and 'Im{f} (GHz)' in labels and row[labels.index('Im{f} (GHz)')] == 0:
                    continue
                assert math.isfinite(value), (path, label, value)
    required = {'electrostatic': {'E', 'V'}, 'magnetostatic': {'B', 'J_s'},
                'driven': {'E_real', 'E_imag', 'J_s_real', 'J_s_imag'},
                'eigenmode': {'E_real', 'E_imag'}}[case]
    assert required <= names, (platform, case, required - names)
    return dict(platform=platform, case=case, vtu_files=len(vtk), fields=sorted(names))


def main():
    manifest = json.loads((BASE / 'inputs.json').read_text())
    assert manifest['acceptance_sha256'] == hashlib.sha256((ROOT / 'docs/GATE3_ACCEPTANCE.json').read_bytes()).hexdigest()
    output_records = []
    for item in manifest['cases']:
        case = item['case']
        for platform in ('windows', 'linux'):
            folder = BASE / platform / case
            assert hashlib.sha256((folder / 'config.json').read_bytes()).hexdigest() == item['configuration_sha256']
            assert hashlib.sha256((folder / item['mesh']).read_bytes()).hexdigest() == item['mesh_sha256']
            raw = (folder / 'run.log').read_bytes()
            log = raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8', errors='replace')
            assert 'Running with 1 MPI process' in log and 'libCEED backend: /cpu/self/opt/blocked' in log
            output_records.append(structural(platform, case))
    compare_matrix('electrostatic', 'terminal-C.csv', 'C')
    compare_matrix('magnetostatic', 'terminal-M.csv', 'M')
    rule = RULES['driven']; w, l = scattering('windows'), scattering('linux')
    assert len(w) == len(l) == len(rule['frequencies_GHz'])
    for expected, fw, fl in zip(rule['frequencies_GHz'], sorted(w), sorted(l)):
        check(f'frequency/windows/{expected}', fw, expected, rule['frequency_absolute_GHz'], 0)
        check(f'frequency/linux/{expected}', fl, expected, rule['frequency_absolute_GHz'], 0)
        for pair in w[fw]:
            check(f'S{pair}@{expected}GHz', w[fw][pair], l[fl][pair], rule['absolute'], rule['relative'])
    rule = RULES['eigenmode']; modes = []
    for platform in ('windows', 'linux'):
        labels, rows = table(BASE / platform / 'eigenmode/output/eig.csv')
        modes.append(sorted([dict(zip(labels, row)) for row in rows], key=lambda r: r['Re{f} (GHz)']))
        assert len(rows) == rule['required_modes']
    for index, (w, l) in enumerate(zip(*modes), 1):
        for platform, row in [('windows', w), ('linux', l)]:
            assert 0 <= row['Error (Bkwd.)'] <= rule['backward_residual_max'], (platform, index, 'residual')
        check(f'eigenfrequency-{index}', complex(w['Re{f} (GHz)'], w['Im{f} (GHz)']), complex(l['Re{f} (GHz)'], l['Im{f} (GHz)']), rule['frequency_absolute_GHz'], rule['frequency_relative'])
        for label, prefix in [('Error (Bkwd.)', 'backward_residual'), ('Error (Abs.)', 'absolute_residual')]:
            check(f'eigen-{index}/{label}', w[label], l[label], rule[prefix + '_absolute'], rule[prefix + '_relative'])
    passed = all(c['passed'] for c in CHECKS)
    report = dict(passed=passed, acceptance_sha256=manifest['acceptance_sha256'], checks=CHECKS, outputs=output_records,
                  max_fraction_of_allowance=max(c['absolute_error']/c['allowed_error'] for c in CHECKS if c['allowed_error']))
    (BASE / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(CHECKS)} numerical checks; passed={passed}; maximum fraction of allowance={report["max_fraction_of_allowance"]:.6g}')
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
