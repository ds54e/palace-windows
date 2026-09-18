# V1.0 implementation contract

## Fixed requirements

The distribution version is 1.0.0; upstream Palace is independently pinned in `deps/upstream.json`. Target Windows 11 x64 on a standard user account, with native execution and no system runtime installation. Windows 10 is not advertised until tested. Preserve the current private repository visibility until the owner authorizes publication.

Primary artifact: portable ZIP. A per-user installer under `%LOCALAPPDATA%\Programs\Palace` is optional and must never request elevation. End users need only the artifact and prepared model inputs. Pre-meshed examples remove the need for Gmsh merely to try the solver. ParaView is an optional external viewer, not a runtime dependency.

## Required behavior

| Area | Acceptance intent |
| --- | --- |
| Electrostatic | C matrix and expected result files |
| Magnetostatic | L matrix, mutual terms, magnetic field output |
| Driven | Lumped ports, complete requested complex S matrix, field output |
| Eigenmode | Basic linear eigenfrequency problem and residual checks |
| Visualization | ParaView-compatible field files; surface-current output verified |
| RF exchange | At least valid `.s1p`/`.s2p` export with explicit port order and common real reference impedance |
| Windows UX | Whitespace/Unicode paths, writable output outside install directory, exit codes, logs, interruption |
| Deployment | No developer tools or centrally installed numerical/MPI runtime required |

Touchstone generation must reject missing matrix entries rather than invent zeros. Solver defaults and unsupported settings must be documented. Do not silently reinterpret input or change numerical tolerances.

Not release blockers: GPU, transient, numeric wave ports, nonlinear eigenproblems, Floquet features, arbitrary point probes, GUI, mesh/CAD generation, QFN generator, mixed-mode conversion, full upstream test-suite parity, multi-process MPI, benchmark speed targets, or a size target guessed before measurement.

## Gates

| Gate | Work and required evidence |
| --- | --- |
| G0_runtime | Application-local MPI singleton works as native Windows; loaded module path is recorded; standard user, no system MPI/services, clean host and offline operation are independently checked |
| G1_abi | C/C++/Fortran/MPI/BLAS interface tests; tiny MUMPS linear solve and PARPACK eigenproblem; LP64/interface settings recorded |
| G2_build | Pinned Palace and dependencies build from scripts; source patches explained; expected CPU backend selected; no manual IDE-only steps |
| G3_numerics | C/L/driven/basic-eigen cases compared with the same upstream commit and inputs on Linux; fields and S export validated |
| G4_package | ZIP, runtime inventory, licenses/notices, build manifest, example inputs, hashes, and separate debug symbols where available |
| G5_clean_host | Packaged artifact tested on clean standard-user Windows, offline, with no MPI/SDK/toolchain; install/run/cancel/re-run/uninstall and Windows path tests |
| G6_reproduce | Build recreated from scripts without relying on an irreplaceable cache; source, patch, and runtime identities recorded |
| G7_review | Redistribution evidence reviewed; unsupported features and signature status disclosed; owner receives release-ready artifacts |

A passed prerequisite does not automatically pass later gates. Gate 0's probe is not Palace numerical validation. `tools/check_readiness.py --ready` checks evidence structure/hashes, not truth of the underlying experiment and not legal compliance.

## Engineering choices still open

Initial candidate: MSVC + compatible Intel Fortran + one BLAS implementation + MUMPS + ARPACK/PARPACK. Do not lock compiler marketing versions before inspecting the actual installed toolchain and compatibility. SuperLU_DIST is a fallback only when evidence makes it the simpler route. Do not switch backends for elegance after a working stack is frozen.

CPU, one rank and one thread are the validation baseline. Measure a threaded configuration only after reproducible baseline success; freeze one shipping policy. One rank does not intrinsically limit x64 process memory to 4 GB, and multiple ranks on the same PC do not add physical RAM.

## Owner-authorized v1.0.0 release exception — 2026-09-18

The owner explicitly authorizes public v1.0.0 publication of the exact frozen METIS-remediated artifact while the independent clean standard-user offline Windows test remains deferred. This does **not** mark G0 or G5 as passed and does not satisfy the strict all-gates `READY_FOR_RELEASE_REVIEW` contract below. Public release notes and README must disclose that clean-machine portability is unverified and that the binaries are unsigned. Any payload-byte change requires a new artifact identity and validation; this exception applies only to the recorded v1.0.0 SHA-256.

## Done means

All gates have passed with source-bound evidence, the package has been exercised without developer-machine dependencies, and outstanding claims are accurately disclosed. Record `READY_FOR_RELEASE_REVIEW`, not a public release. Public visibility, final tag/release publication, paid signing, and external announcements remain owner-controlled actions.
