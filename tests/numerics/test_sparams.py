"""Exercise the native Windows exporter; Python is developer-only."""
import cmath
import csv
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[2]
EXE = ROOT / '.work/build/sparams/palace-sparams.exe'
WORK = ROOT / '.work/gate3/sparams-tests'


def win(path):
    return subprocess.check_output(['wslpath', '-w', str(path)], text=True).strip()


class ExportTests(unittest.TestCase):
    def setUp(self):
        WORK.mkdir(parents=True, exist_ok=True)
        self.input = WORK / 'phase input.csv'
        self.output = WORK / '出力 matrix.s2p'
        self.output.unlink(missing_ok=True)
        self.input.write_text('f (GHz),|S[1][1]| (dB),arg(S[1][1]) (deg.),|S[2][1]| (dB),arg(S[2][1]) (deg.),|S[1][2]| (dB),arg(S[1][2]) (deg.),|S[2][2]| (dB),arg(S[2][2]) (deg.)\n1,0,90,-20,180,-40,-90,-60,0\n')

    def run_export(self, ports=('1', '2'), output=None, source=None):
        return subprocess.run([str(EXE), win(source or self.input), win(output or self.output), '50', *ports], capture_output=True)

    def test_complex_order_unicode_and_overwrite(self):
        result = self.run_export()
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = self.output.read_text().splitlines()
        self.assertIn('# GHz S RI R 50', lines)
        data = [float(v) for v in lines[-1].split()]
        for actual, expected in zip([complex(*data[i:i+2]) for i in range(1,9,2)], [1j,-.1,-.01j,.001]):
            self.assertLess(abs(actual-expected), 1e-14)
        self.assertNotEqual(self.run_export().returncode, 0)

    def test_missing_matrix_rejected(self):
        self.input.write_text('f (GHz),|S[1][1]| (dB),arg(S[1][1]) (deg.)\n1,0,0\n')
        self.assertNotEqual(self.run_export().returncode, 0)
        self.assertFalse(self.output.exists())

    def test_nonfinite_rejected(self):
        self.input.write_text(self.input.read_text().replace('0,90', 'nan,90'))
        self.assertNotEqual(self.run_export().returncode, 0)
        self.assertFalse(self.output.exists())

    def test_single_port_and_reversed_order(self):
        one=WORK/'one.s1p'; one.unlink(missing_ok=True)
        self.assertEqual(self.run_export(('2',),one).returncode,0)
        self.assertEqual(len(one.read_text().splitlines()[-1].split()),3)
        self.assertEqual(self.run_export(('2','1')).returncode,0)
        data=[float(v) for v in self.output.read_text().splitlines()[-1].split()]
        for actual,expected in zip([complex(*data[i:i+2]) for i in range(1,9,2)],[.001,-.01j,-.1,1j]):
            self.assertLess(abs(actual-expected),1e-14)

    def test_all_gate3_frequencies_complex(self):
        source=ROOT/'.work/gate3/windows/driven/output/port-S.csv'
        self.assertEqual(self.run_export(source=source).returncode,0)
        with source.open() as f: rows=list(csv.reader(f))[1:]
        data=[list(map(float,line.split())) for line in self.output.read_text().splitlines() if line and line[0] not in '!#']
        self.assertEqual(len(data),3)
        for csvrow,outrow in zip(rows,data):
            values=list(map(float,csvrow)); self.assertEqual(values[0],outrow[0])
            for i in range(1,9,2):
                expected=cmath.rect(10**(values[i]/20),values[i+1]*cmath.pi/180)
                self.assertLess(abs(expected-complex(*outrow[i:i+2])),1e-14)

if __name__=='__main__': unittest.main()
