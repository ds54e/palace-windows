"""Overlapping source patches must be idempotent and fail atomically."""
import difflib
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from prepare_gate2 import apply

class PatchSequence(unittest.TestCase):
    def fixture(self, root):
        tree = root / 'tree'
        tree.mkdir()
        original = 'before\nalpha\nafter\n'
        intermediate = original.replace('alpha', 'beta')
        final = original.replace('alpha', 'gamma')
        (tree / 'input.txt').write_text(original)
        patches = []
        for index, (old, new) in enumerate([(original, intermediate), (intermediate, final)]):
            patch = root / f'{index}.patch'
            patch.write_text(''.join(difflib.unified_diff(old.splitlines(True), new.splitlines(True),
                                                        fromfile='a/input.txt', tofile='b/input.txt')))
            patches.append(patch)
        return tree, patches, original, final

    def test_overlap_and_repeat(self):
        with tempfile.TemporaryDirectory() as temporary:
            tree, patches, _, final = self.fixture(Path(temporary))
            apply(tree, patches)
            self.assertEqual((tree / 'input.txt').read_text(), final)
            stamp = (tree / 'input.txt').stat().st_mtime_ns
            apply(tree, patches)
            self.assertEqual((tree / 'input.txt').read_text(), final)
            self.assertEqual((tree / 'input.txt').stat().st_mtime_ns, stamp)

    def test_failure_preserves_original(self):
        with tempfile.TemporaryDirectory() as temporary:
            tree, patches, original, _ = self.fixture(Path(temporary))
            patches[1].write_text(patches[1].read_text().replace('-beta', '-not-present'))
            with self.assertRaises(subprocess.CalledProcessError):
                apply(tree, patches)
            self.assertEqual((tree / 'input.txt').read_text(), original)

if __name__ == '__main__':
    unittest.main()
