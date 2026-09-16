#!/usr/bin/env python3
"""Check smoke artifacts structurally; this is not Linux numerical equivalence."""
import base64
import csv
import hashlib
import json
import math
from pathlib import Path
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / '.work/gate2/palace-smoke'


def check_vtu(path):
    data = path.read_bytes()
    marker = b'<AppendedData encoding="raw">'
    start = data.find(marker)
    payload = None
    if start >= 0:
        begin = data.index(b'_', start) + 1
        end = data.rindex(b'</AppendedData>')
        payload = data[begin:end]
        data = data[:start] + data[end + len(b'</AppendedData>'):]
    root = ET.fromstring(data)
    assert root.get('byte_order') == 'LittleEndian'
    assert root.get('compressor') is None, 'Unexpected compressed representation'
    width = 8 if root.get('header_type') == 'UInt64' else 4
    code = '<Q' if width == 8 else '<I'
    names = []
    for array in root.iter('DataArray'):
        kind = array.get('format')
        if kind == 'appended':
            offset = int(array.attrib['offset'])
            size = struct.unpack_from(code, payload, offset)[0]
            values = payload[offset + width:offset + width + size]
            assert len(values) == size
        elif kind == 'binary':
            text = ''.join((array.text or '').split())
            header_chars = 4 * ((width + 2) // 3)
            size = struct.unpack(code, base64.b64decode(text[:header_chars]))[0]
            values = base64.b64decode(text[header_chars:])
            assert len(values) == size, (path, array.attrib, size, len(values))
        else:
            assert kind == 'ascii'
            assert all(math.isfinite(float(v)) for v in (array.text or '').split())
            continue
        dtype = array.get('type')
        if dtype in ('Float32', 'Float64'):
            fmt = '<f' if dtype == 'Float32' else '<d'
            assert all(math.isfinite(v[0]) for v in struct.iter_unpack(fmt, values)), path
        names.append(array.get('Name', 'coordinates'))
    return names


def main():
    records = []
    for case in ('electrostatic', 'magnetostatic', 'driven', 'eigenmode'):
        folder = BASE / case / 'output'
        csv_files = list(folder.glob('*.csv'))
        assert csv_files
        for path in csv_files:
            rows = list(csv.reader(path.open()))
            assert len(rows) > 1, path
            for row in rows[1:]:
                assert len(row) == len(rows[0]), path
                assert all(math.isfinite(float(v)) for v in row), path
        vtk_files = list(folder.rglob('*.vtu'))
        assert vtk_files, f'{case}: no ParaView fields'
        fields = set()
        for path in vtk_files:
            fields.update(check_vtu(path))
        for path in list(folder.rglob('*.pvd')) + list(folder.rglob('*.pvtu')):
            tree = ET.parse(path)
            for node in tree.iter():
                target = node.get('file') or node.get('Source')
                if target:
                    assert (path.parent / target).is_file(), (path, target)
        files = csv_files + vtk_files
        records.append({'case': case, 'csv_count': len(csv_files), 'vtu_count': len(vtk_files),
                        'fields': sorted(fields), 'artifacts': [
                            {'path': str(p.relative_to(ROOT)), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                            for p in files]})
    driven = list(csv.reader((BASE / 'driven/output/port-S.csv').open()))
    header = [v.strip() for v in driven[0]]
    for i in (1, 2):
        for j in (1, 2):
            assert f'|S[{i}][{j}]| (dB)' in header
            assert f'arg(S[{i}][{j}]) (deg.)' in header
    # Use the input's predeclared eigen tolerance, never fit a limit to results.
    config = json.loads((BASE / 'eigenmode/config.json').read_text())
    eig = list(csv.reader((BASE / 'eigenmode/output/eig.csv').open()))
    columns = [v.strip() for v in eig[0]]
    tolerance = config['Solver']['Eigenmode']['Tol']
    assert len(eig) - 1 == config['Solver']['Eigenmode']['N']
    assert all(float(row[columns.index('Error (Bkwd.)')]) <= tolerance for row in eig[1:])
    report = {'scope': 'Finite CSV/VTU values, VTK references and complete 2x2 S data; not independent viewer or Linux equivalence',
              'eigen_backward_tolerance': tolerance, 'cases': records}
    (ROOT / '.work/gate2/smoke-output-check.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Four solver outputs checked: finite CSV/VTU, VTK references, complete 2x2 S, eigen residuals.')


if __name__ == '__main__':
    main()
