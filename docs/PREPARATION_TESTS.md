# Preparation test report — 2026-09-16

Environment: Linux preparation container, Python 3.13.5. This is not the user's WSL/Windows workstation.

| Check | Result |
| --- | --- |
| `python tools/check_readiness.py` | PASS: pending state is structurally valid |
| `python -m unittest discover -s tests/python -v` | PASS: 14 tests |
| `python tools/check_readiness.py --ready` | Expected rejection, exit 1: all V1 gates still unexecuted |
| `bash -n tools/windows.sh` | PASS: shell syntax |
| Parse committed JSON/TOML files | PASS: Python standard-library parsers |
| Resolve relative Markdown links | PASS |

Not executed: native PowerShell script parsing/runtime, C++ MPI compilation/runtime, app-local DLL loading, Windows toolchain setup, clean-host deployment, Palace compilation, solver numerical comparisons, GitHub Actions, or optional Codex child-role activation.

The MPI and Windows scripts are implementation starting points that require native execution. These preparation checks must not be cited as a passed V1 gate or a working Windows Palace executable.
