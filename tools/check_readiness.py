#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Validate V1 state/evidence structure. This cannot prove the reports are true."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

GATES = ('G0_runtime', 'G1_abi', 'G2_build', 'G3_numerics', 'G4_package',
         'G5_clean_host', 'G6_reproduce', 'G7_review')
STATUSES = {'not_run', 'in_progress', 'blocked', 'pass', 'fail'}

def inspect_state(state, root, require_ready=False):
    """Return problems; reject path escapes, missing evidence and altered hashes."""
    errors = []
    root = Path(root).resolve()
    if not isinstance(state, dict):
        return ['State must be a JSON object.']
    if state.get('schema_version') != 1:
        errors.append('schema_version must be 1.')
    if state.get('current_gate') not in GATES:
        errors.append('current_gate must name a known gate.')
    gates = state.get('gates')
    if not isinstance(gates, dict) or set(gates) != set(GATES):
        return errors + ['State must contain exactly the required gates.']
    for name in GATES:
        gate = gates[name]
        if not isinstance(gate, dict):
            errors.append(name + ': gate must be an object.'); continue
        status = gate.get('status')
        if status not in STATUSES:
            errors.append(name + ': invalid status.')
        if require_ready and status != 'pass':
            errors.append(name + ': not passed.')
        evidence = gate.get('evidence')
        if not isinstance(evidence, list):
            errors.append(name + ': evidence must be a list.'); continue
        if status == 'pass' and not evidence:
            errors.append(name + ': pass requires evidence.')
        for item in evidence:
            if not isinstance(item, dict):
                errors.append(name + ': evidence item must be an object.'); continue
            text, digest = item.get('path'), item.get('sha256')
            if not isinstance(text, str) or not text or '\\' in text or re.match(r'^[A-Za-z]:', text):
                errors.append(name + ': use a repository-relative forward-slash path.'); continue
            rel = Path(text)
            if rel.is_absolute() or '..' in rel.parts:
                errors.append(name + ': evidence path escapes repository.'); continue
            path = (root / rel).resolve()
            try:
                path.relative_to(root)
            except ValueError:
                errors.append(name + ': resolved evidence escapes repository.'); continue
            if not isinstance(digest, str) or not re.fullmatch('[0-9a-f]{64}', digest):
                errors.append(name + ': invalid evidence SHA256.'); continue
            if not path.is_file():
                errors.append(name + ': missing evidence file: ' + text); continue
            try:
                data = path.read_bytes()
            except OSError as exc:
                errors.append(name + ': cannot read evidence: ' + str(exc)); continue
            if not data:
                errors.append(name + ': evidence file is empty.')
            if hashlib.sha256(data).hexdigest() != digest:
                errors.append(name + ': evidence hash mismatch: ' + text)
    if require_ready and state.get('project_status') != 'READY_FOR_RELEASE_REVIEW':
        errors.append('project_status is not READY_FOR_RELEASE_REVIEW.')
    return errors

def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--state', type=Path)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--ready', action='store_true', help='Fail unless all gates have hashed evidence and review-ready state.')
    args = parser.parse_args(argv)
    state_path = args.state or args.root / 'docs' / 'STATE.json'
    try:
        state = json.loads(state_path.read_text(encoding='utf-8'))
        errors = inspect_state(state, args.root, args.ready)
    except (OSError, ValueError) as exc:
        print('Invalid state: ' + str(exc), file=sys.stderr); return 2
    if errors:
        print('\n'.join(errors), file=sys.stderr); return 1
    print('PASS: ' + ('readiness evidence structure' if args.ready else 'state structure') + ' (not an independent verification of claims)')
    return 0

if __name__ == '__main__':
    sys.exit(main())
