import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import compare_gate3 as compare


class ComparisonChecks(unittest.TestCase):
    def setUp(self):
        compare.CHECKS.clear()

    def test_phase_only_error_cannot_pass_magnitude_comparison(self):
        compare.check('phase-only', 1+0j, 0+1j, 1e-7, 1e-6)
        self.assertFalse(compare.CHECKS[-1]['passed'])

    def test_small_value_uses_absolute_allowance(self):
        compare.check('near-zero', 1e-19, 0, 1e-18, 1e-6)
        self.assertTrue(compare.CHECKS[-1]['passed'])

    def test_matrix_labels_determine_entries(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'matrix.csv'
            path.write_text('i,C[i][2] (F),C[i][1] (F)\n2,4,-1\n1,-1,2\n')
            self.assertEqual(compare.matrix(path, 'C'), {1: {1: 2, 2: -1}, 2: {1: -1, 2: 4}})


if __name__ == '__main__':
    unittest.main()
