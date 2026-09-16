# Gate 3: Windows/Linux numerical equivalence

Status: in progress. Acceptance was committed before inspecting Linux Palace comparison results (`docs/GATE3_ACCEPTANCE.json`, initial commit `2bd375b`; lossless-Q structural clarification before Linux results in `34dca93`). No numerical tolerance has been widened.

Both paths use Palace v0.18.0 commit `b92aef83ecfe6d360c4b3d83e2122986297f6778`, MPI enabled, Hypre, METIS, MUMPS PORD/METIS and ARPACK/PARPACK; ParMETIS implementation is absent. The Linux reference overlay only adapts the Windows variant's CMake guards to permit the same selected dependency semantics. Solver code and fixed input selections are shared. The configurations and meshes are copied byte-for-byte and hash checked. CPU backend `/cpu/self/opt/blocked`, one MPI rank, and one numerical thread are explicit.

| Identity | Windows candidate | Linux reference |
| --- | --- | --- |
| C/C++ | MSVC 19.44.35219.0; IntelLLVM C99 for libCEED | GCC/G++ 11.5.0 (AlmaLinux 9) |
| Fortran | Intel ifx 2025.3.0, build 20251010 | GNU Fortran 11.5.0, matching extracted AlmaLinux package |
| MPI | MS-MPI 10.1.12498.18 app-local singleton | Open MPI 4.1.1 extracted repository-local, singleton |
| BLAS/LAPACK | oneMKL 2025.3 LP64 sequential | OpenBLAS 0.3.29 serial LP64 |
| Distributed dense support | oneMKL ScaLAPACK / MS-MPI BLACS | upstream ScaLAPACK 2.2.2, commit 6423f17933eb9a2522814b78ab3c0d6da25ee85a, Open MPI BLACS |
| Numerical integer contract | 32-bit C/Fortran/BLAS/MUMPS/METIS/Hypre interfaces | same 32-bit numerical interfaces; Linux host `long` differs from Windows LLP64 |
| Electrostatic / Driven | MUMPS, explicit METIS ordering | identical |
| Magnetostatic | AMS/CG, fixed 1e-8 input tolerance | identical |
| Eigenmode | ARPACK, MUMPS, explicit METIS ordering, two modes | identical |

Compiler/MPI and numerical-library implementations are platform differences under test; the selected solver families, source revisions, ordering and no-ParMETIS semantics are matched. The Linux packages are extracted, not installed system-wide, and are not shipped in the Windows artifact. Exact package URLs/hashes and source/patch identities are in `deps/linux-reference-lock.json` plus its inherited locks.

Commands (developer only):

1. `python3 tools/prepare_linux_reference.py --verify` verifies extracted inputs/source patches.
2. `bash scripts/build-linux-reference.sh <component>` builds the reference components in the documented order: metis, scalapack, mumps, hypre, mfem, arpack, ceed, core, palace.
3. `bash scripts/test-linux-mumps.sh` and `bash scripts/test-linux-connections.sh` run the original connection checks.
4. `python3 tools/prepare_gate3_cases.py` prepares the identical inputs; do not rerun to overwrite assessed evidence without recording a new attempt.
5. Native `scripts/run-gate3-windows.ps1` and `bash scripts/run-gate3-linux.sh` run the four cases.
6. In `scripts/linux-reference-env.sh` scope, `python3 tools/audit_linux_reference.py` records actual compiler/math/artifact identities and checks archives, runtime imports and link map for ParMETIS artifacts.
7. `python3 tools/compare_gate3.py` checks all C/L entries and scalar invariants, all complex S entries at 4/5/6 GHz, eigenfrequencies/residuals and structural output validity. It does not compare raw eigenvectors or demand identical CSV/VTU bytes.

The native Touchstone exporter is separately tested on the Windows driven output, with phase/order/missing-entry checks. Developer-host comparison success does not establish clean-host deployment, redistribution rights, multi-rank scaling or broader numerical coverage.
