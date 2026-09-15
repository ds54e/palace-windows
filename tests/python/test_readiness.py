# SPDX-License-Identifier: Apache-2.0
import copy
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('readiness', ROOT / 'tools' / 'check_readiness.py')
r = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r)

class ReadinessTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.state = {'schema_version': 1, 'current_gate': r.GATES[0], 'project_status': 'PREPARATION_ONLY',
                      'gates': {g: {'status': 'not_run', 'evidence': []} for g in r.GATES}}
    def evidence(self, name='report.txt', data=b'test evidence'):
        (self.root / name).write_bytes(data)
        return {'path': name, 'sha256': hashlib.sha256(data).hexdigest()}
    def test_pending_structure_is_valid(self):
        self.assertEqual(r.inspect_state(self.state, self.root), [])
    def test_pending_is_not_ready(self):
        self.assertTrue(r.inspect_state(self.state, self.root, True))
    def test_all_gates_need_evidence(self):
        for g in self.state['gates'].values(): g['status'] = 'pass'
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_complete_structure(self):
        e = self.evidence()
        for g in self.state['gates'].values(): g.update(status='pass', evidence=[e])
        self.state['project_status'] = 'READY_FOR_RELEASE_REVIEW'
        self.assertEqual(r.inspect_state(self.state, self.root, True), [])
    def test_mismatched_hash(self):
        e = self.evidence(); e['sha256'] = '0' * 64
        self.state['gates'][r.GATES[0]].update(status='pass', evidence=[e])
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_missing_file(self):
        self.state['gates'][r.GATES[0]].update(status='pass', evidence=[{'path':'absent','sha256':'0'*64}])
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_parent_escape(self):
        self.state['gates'][r.GATES[0]]['evidence'] = [{'path':'../outside','sha256':'0'*64}]
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_windows_absolute_path(self):
        self.state['gates'][r.GATES[0]]['evidence'] = [{'path':'C:/outside','sha256':'0'*64}]
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_unknown_gate(self):
        self.state['gates']['surprise'] = {'status':'pass','evidence':[]}
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_unknown_status(self):
        self.state['gates'][r.GATES[0]]['status'] = 'looks_good'
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_empty_file(self):
        e = self.evidence(data=b'')
        self.state['gates'][r.GATES[0]].update(status='pass', evidence=[e])
        self.assertTrue(r.inspect_state(self.state, self.root))
    def test_nonobject_state(self):
        self.assertTrue(r.inspect_state([], self.root))
    def test_symlink_escape(self):
        with tempfile.TemporaryDirectory() as other:
            outside = Path(other) / 'secret.txt'; outside.write_bytes(b'x')
            try: (self.root / 'link').symlink_to(outside)
            except OSError: self.skipTest('symlinks unavailable')
            self.state['gates'][r.GATES[0]]['evidence'] = [{'path':'link','sha256':hashlib.sha256(b'x').hexdigest()}]
            self.assertTrue(r.inspect_state(self.state, self.root))
    def test_bad_json_main(self):
        p = self.root / 'bad.json'; p.write_text('{', encoding='utf-8')
        self.assertEqual(r.main(['--state',str(p),'--root',str(self.root)]), 2)

if __name__ == '__main__':
    unittest.main()
