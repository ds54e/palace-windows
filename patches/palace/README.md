# Palace Windows overlay

Base: Palace v0.18.0 b92aef83ecfe6d360c4b3d83e2122986297f6778 (Apache-2.0).
`windows-no-parmetis.patch` adds an opt-in, Windows-only build variant. Upstream
non-Windows dependency selection remains intact. It removes ParMETIS convenience
requirements for MUMPS/MFEM and Palace, forwards the variant to inner builds, and
replaces the mixed-compiler rejection with an explicit tested runtime link.
The native libCEED CMake target is discovered and link-tested without requiring
pkg-config. No Palace solver algorithm or ordering enum is changed.

Apply through `tools/prepare_gate2.py`; exact patch hashes are locked in
`deps/gate2-lock.json`. The native scripts are the Windows dependency recipes;
the upstream superbuild configure is an additional graph check, not a claim that
all upstream Unix build commands work on Windows.

`windows-license-notice.patch` adds a Windows-only `--licenses` option and help entry for MUMPS CeCILL-C interface attribution and package license/source locations. It does not change solver behavior. The packaging candidate reruns the frozen Gate 3 cases after rebuilding.
