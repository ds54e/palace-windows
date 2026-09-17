# Engineering log

## 2026-09-16 — Repository preparation

Observed the private repository containing only its initial README. Prepared the V1 contract, bounded Codex model policy, optional configuration templates, source pin, native MPI probe source, Windows diagnostics, and release-readiness tooling.

No local Windows host was accessed. No Palace build, MPI runtime test, clean-Windows test, or numerical validation has passed. Optional Codex child templates have not been activated on the user's CLI. See the preparation report for checks actually run on the preparation environment.

## 2026-09-17 — Model policy simplified

Changed the default Codex parent from Terra/medium to Astra/low by owner decision. Sol/medium is now the owner-controlled cost/quota fallback parent, Luna/medium remains an optional bounded read-only helper, and Terra is removed from the default V1 path. Removed the automatic Sol/high specialist route to keep model routing simple and avoid turning routing into project work. Higher Astra effort still requires explicit owner authorization.

This policy change does not alter any Palace build, runtime, numerical, or release-readiness status. Gate 0 remains not run.

For subsequent entries use: gate/blocker; hypothesis; exact command; source/toolchain identity; result; evidence path/hash; next experiment. Keep full raw logs in `.work/` and commit only sanitized evidence.

## 2026-09-17 — Real host inventory and Gate 0 investigation

Ran the Windows bridge: script execution was rejected by host policy. Completed direct read-only native inventory, verified pinned Palace source, inspected Microsoft MPI singleton source and WelSim prior art, and compiled the supplied probe to a native x64 object with installed MSVC. No link/runtime test or Palace build occurred. No policy, service, system installation, or global Codex setting was changed.

Commands, source/toolchain identities, bounded findings, raw log paths, and next experiments are recorded in `docs/evidence/G0-2026-09-17.md`. Gate 0 is blocked, not passed. Effective model/status metadata is unavailable; project defaults were not treated as observed runtime metadata. No delegation was used.

## 2026-09-17 — Authorized process policy and native MPI execution

Owner explicitly authorized process-only PowerShell bypass for repository workflows. Recorded all policy scopes before proceeding: MachinePolicy/UserPolicy and all other scopes Undefined. Doctor executed successfully; corrected its Windows PowerShell 5.1 VS-array projection and confirmed native inventory. The bridge now uses the authorized process argument without persistent changes.

Downloaded official Microsoft MPI 10.1.12498.18 runtime/SDK, verified SHA256 and Microsoft Authenticode, extracted without executing either installer, and inspected the included binary license terms. Linked and executed the probe using the x64 import library and app-local DLL. Initial dynamic CRT imports led to one controlled change: static CRT for the probe only. Rebuilt and passed functional/app-local checks on the developer machine, including whitespace/Unicode path execution. Import audit now finds no direct VC runtime DLL dependency. Final fresh-process policy list is unchanged.

See `docs/evidence/G0-functional-2026-09-17.md` for exact commands, identities, raw log paths, licensing findings and the next clean-host experiment; payload and sanitized reports are adjacent. No Palace build, numerical comparison, offline test or clean-host pass is claimed. Gate 0 remains blocked on external clean-host evidence and release redistribution review. No children or model switches were used.

## 2026-09-17 — Gate 1 opened by owner; repository-local Intel stack

Pushed checkpoint d48f573 to origin/main (02247dc..d48f573). Owner explicitly authorized engineering beyond Gate 0 functional evidence while clean-host/offline and redistribution review remain open; Gate 0 is not passed.

Inventory (`powershell.exe -NoProfile -NonInteractive -Command` with Get-Command, bounded standard-directory and uninstall-record queries) found no Fortran compiler or oneMKL in the searched locations; logs `.work/gate1/toolchain-inventory.txt` and `toolchain-roots.txt`. No broad filesystem/authentication/environment dump. The current Intel download page documents ifx_win-64; downloaded Intel-channel repodata, selected 2025.3.0 and its concrete dependencies, verified vendor SHA256, and extracted locally using Python ZIP/tar and zstd. No conda/system installer was run. Exact packages/hashes are in `deps/gate1-lock.json`; download/extraction logs are `intel-download.log` and `intel-extract.log`. oneMKL static and cluster NuGet 2025.3.0.453 were acquired from the official documented package route and extracted locally. Compiler invocation through `tools/native-dev.cmd ifx.exe --version` succeeded: 2025.3.0 build 20251010. Recorded MSVC 19.44.35219.0/SDK 10.0.22621.0 remain in use. See `docs/ABI_CONTRACT.md` for selected ABI, rationale, sources, and fixed numerical tolerances.

Command prefix for builds: `cmd.exe /d /c '<repo>\tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <repo>\scripts\SCRIPT.ps1'`. Only process-local environment and authorized process execution policy are changed.

- `build-gate1.ps1`: first attempt (`build-connection.log`) exposed missing installed SDK alias mpifptr.h. Restored that name by copying exact mpifptr64.h bytes; second attempt (`build-connection-sdk-layout.log`) compiled, linked and passed mixed C/C++/Fortran/MPI/oneMKL test. Native result reports 32-bit integer/logical/MPI_Fint/MKL_INT and 64-bit pointers, 16-byte complex. Extended CHARACTER argument coverage will be rerun with the solver tests. Direct import report: `connection-imports.txt`; this developer-host test uses VC and Intel DLL CRTs, not yet an isolated deployment closure.
- Cloned Palace-pinned ARPACK and MUMPS wrapper commits (logs `arpack-fetch.log`, `mumps-fetch.log`) and applied exact Palace patches. Downloaded MUMPS 5.7.3 from its upstream URL, hash 84a47f7c4231b9efdf4d4f631a2cae2bdd9adeaabc088261d15af040143ed112.
- `build-gate1-solvers.ps1`: initial `build-solvers.log` identified missing MPI include-cache hints; corrected explicit SDK hints. `build-solvers-mpi-layout.log`, `build-solvers-test-port.log`, and `build-solvers-c-complex.log` exposed MSVC unsupported VLA/complex operators in upstream C tests. Ported fixed dimensions to enum bounds and used UCRT complex multiplication on MSVC, preserving checks/tolerances; no test was disabled to make this build pass. Patch provenance is in `patches/arpack-ng/README.md`.
- `build-solvers-parpack-test-port.log`: ARPACK/PARPACK including upstream test executables built; MUMPS configure lacked SCALAPACK::SCALAPACK after Palace's patch removed the wrapper finder. The wrapper's direct FetchContent_Populate also ignored the attempted source-dir override and re-downloaded MUMPS; independently verified the re-downloaded hash matches. Added a local archive/hash patch and a ScaLAPACK finder that link-checks the actual pdgemm Fortran symbol. Next attempt log: `build-solvers-scalapack.log`.
- Upstream ARPACK test listing shows 13 tests. An attempted command-line exclusion did not take effect through cmd quoting: `arpack-serial-tests.log` records 10 executed passes and 3 not-run MPI-launcher tests, not a whole-suite pass. A PowerShell-driven explicitly scoped rerun is needed; no mpiexec/service installation is authorized or required for the V1 singleton baseline.

Raw logs named above are under `.work/gate1/`. Only source/metadata/evidence are tracked. Next discriminating experiment: finish the actual parallel MUMPS build, then execute tiny MUMPS and complex PARPACK regular/shift-invert solves at predeclared tolerances. No full Palace success is claimed.

### Gate 1 completion — developer-host scope

MUMPS configure follow-ups: `build-solvers-scalapack.log` and `build-solvers-cmake-path.log` exposed backslashes embedded into CMake try_compile scripts. Normalized all CMake library/include list arguments to forward slashes. `build-solvers-normalized.log` retained the earlier failed pdgemm check in cache; the finder now keys that check by library/compiler/flags signature and reruns on changed inputs. `build-solvers-link-recheck.log` passed the actual pdgemm link check, built parallel double-real MUMPS 5.7.3 (299 build steps) and retained PORD ordering. Fortran static archiver warned that /machine:x64 is ignored; resulting archives linked into native x64 tests successfully.

`build-gate1.ps1 -Solvers` (`.work/gate1/solver-tests.log`) compiled and ran all three tests successfully. MUMPS solution residual infinity norm: 1.77636e-15. Complex PARPACK regular/shift-invert maximum residuals: 6.93966e-14 and 7.12592e-13. The mixed test includes the Fortran CHARACTER hidden-length MPI call and default-width checks. Tolerances were fixed in source before these runs and not widened. `scripts/test-arpack.ps1` (`arpack-serial-tests-scoped.log`) correctly scoped the serial suite: 10/10 passed; three upstream two-rank tests remain unexecuted. Native test outputs, source/script/archive/executable hashes and limitations are in `docs/evidence/G1-developer-2026-09-17.json`.

Gate 1 passes for this developer-host ABI/PORD connection scope. Gate 0 remains blocked on clean-host/offline and release review, by the owner's explicit permission to proceed. Next gate is G2; no Palace distribution exists yet. Fetched pinned MFEM d9d6526cc1749980a2ba1da16e2c1ca1e07d82ec and libCEED 39f259f89332e936122f7e02d6088a1dae3fb628 for source inspection, logs `.work/gate1/mfem-fetch.log` and `libceed-fetch.log`.

## 2026-09-17 — Gate 2 native METIS and external licensing blocker

Committed/pushed the completed G1 checkpoint as 139e042. Continued executable work beyond G1 on the same developer host without system installation or elevation.

Resolved Palace's METIS/ParMETIS tags to actual commits with `git ls-remote` and fetched `https://bitbucket.org/petsc/pkg-metis.git` at 08c3082720ff9114b8e3cbaa4484a26739cd7d2d and `https://bitbucket.org/petsc/pkg-parmetis.git` at 53c9341b6c1ba876c97567cb52ddfc87c159dc36 into `.work/sources/metis` and `.work/sources/parmetis`. Raw pin/fetch logs are `.work/gate2/{metis,parmetis}-{pin.txt,fetch.log}`. Source and license identities are preserved in `docs/evidence/G2-partial-2026-09-17.json`.

Using the same native command prefix recorded for G1, executed `scripts/build-metis.ps1`: static MSVC /MD, 32-bit idx_t/real_t, assertions enabled, optimized flags without NDEBUG, repository-local install. Build/install passed (`.work/gate2/metis-build.log`). The separate `tests/metis` connection test passed partition range/nonempty-partition/recomputed-cut and ordering-permutation checks (`.work/gate2/metis-connection.log`, `.work/build/metis-probe/Testing/Temporary/LastTest.log`): edge cut 2. No numerical tolerance was relaxed.

Executed `scripts/configure-gate2.ps1` with Palace v0.18.0's exact source and explicit G1 toolchain/MPI/LP64 library inputs. Configure failed at `cmake/ExternalMFEM.cmake:216`, which rejects Intel Fortran with a non-Intel C++ compiler and later assumes ifport/ifcore runtime library names. Log: `.work/gate2/palace-configure.log`. G1 demonstrates mixed cl/ifx can work, but the full MFEM link needs an explicit Windows runtime-link port and test; the guard was not simply suppressed. The configure also displays default Release NDEBUG flags; these must be replaced with the required assertion-preserving settings before a full build. No Palace build was attempted. This script is a reproducible failing investigation, not the completed production recipe.

Independent source review found ParMETIS's exact pinned LICENSE.txt requires prior approval for redistribution. Palace's `palace/CMakeLists.txt` unconditionally finds/links ParMETIS; ExternalMUMPS and ExternalMFEM also request it. No approval evidence is present. This is an external licensing blocker for the selected release stack, not evidence that local evaluation or every possible alternative build is impossible. ParMETIS was not built or packaged. METIS's separate Apache-2.0 license does not grant ParMETIS permissions. See `docs/REDISTRIBUTION.md`.

Additional bounded inspection: the extracted Intel compiler_shared package contains icx-cl.exe but lacks its required clang-cl.exe frontend; `icx-cl.exe --version` ends with error 10408 (`.work/gate2/icx-version.log`). Do not count this as an available C compiler. Official Intel dpcpp packages offer a potential repository-local route, not yet downloaded/tested. libCEED/GSLIB need native recipes instead of forwarding Makefile variables to Ninja; libCEED also needs a defensible Windows allocation/C99 port. These are engineering tasks, not privilege blockers.

Next discriminating action: obtain applicable ParMETIS redistribution approval evidence, or explicitly select/document a no-ParMETIS variant and test its remaining ordering/partitioning behavior before resuming the full recipe. Then address the MFEM runtime guard, assertion flags, and native libCEED/GSLIB recipes. Stopped at the newly established licensing blocker as authorized by the owner. G1 remains passed within its connection-test scope; G0 remains blocked on clean standard-user/offline evidence and release review. No release, clean-host success, full Palace build, or READY_FOR_RELEASE_REVIEW claim.

## 2026-09-17 — Owner-selected no-ParMETIS overlay

Owner selected MPI-enabled Windows V1 without ParMETIS, explicitly removing approval-seeking from the critical path. Updated D010 and `NO_PARMETIS.md`; retained the pinned restrictive license evidence. Fresh `powershell.exe -NoProfile -NonInteractive -Command 'Get-ExecutionPolicy -List'` still reports all scopes Undefined (`.work/gate2/no-parmetis-policy.txt`). All scripts below use the previously authorized process-only bypass through `tools/native-dev.cmd`; no persistent policy, elevation or system installation.

Source survey traces Palace ExternalMETIS/ExternalMUMPS/ExternalMFEM/inner Palace discovery/linking, disabled solver recipes, MFEM package defaults and MUMPS optional ordering branches. No MPI replacement and no Palace solver algorithm changes. The Windows overlay guards ParMETIS discovery/linkage; MFEM's wrapper preserves the enum and rejects explicit PARMETIS using MFEM_VERIFY. Exact sources, six Palace-selected MFEM upstream patch hashes, and local patch identities are in `deps/gate2-lock.json`.

Commands use `cmd.exe /d /c '<repo>\tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <repo>\scripts\SCRIPT.ps1 [arguments]'`:

- `build-no-parmetis-deps.ps1 -Component metis`: native assertions-enabled static /MD build/install passed into separate `.work/install/no-parmetis`; log `no-parmetis-metis.log`.
- Same script `-Component mumps`: MPI+ScaLAPACK, metis=ON, parmetis=OFF, explicit empty stale ParMETIS hint, PORD retained; native build/install passed (`no-parmetis-mumps.log`). Generated C compilation defines only Add_, metis, pord for the ordering translation unit.
- `test-no-parmetis.ps1`: both explicit Gate 1 PORD/METIS solves passed original tolerances, INFOG(7) confirmed 4/5, residual 1.77636e-15 each. Explicit Intel DLL runtime import libraries were linked by the MSVC C++ linker against a Fortran allocation/I/O routine; compile and execution passed. Raw log `no-parmetis-tests.log`, native CTest log `.work/build/no-parmetis-tests/Testing/Temporary/LastTest.log`.
- Same dependency script `-Component hypre`: pinned fca98afcd78a26b784dc24b0c3edb0e6140598af built/installed with MPI ON, LP64, oneMKL BLAS/LAPACK, no ParMETIS (`no-parmetis-hypre.log`).
- `configure-gate2.ps1`: overlay superbuild now configures successfully, including the real mixed-link check (`no-parmetis-palace-configure.log`). This is graph/configuration evidence only; native per-dependency recipes handle the Windows build.
- `build-mfem.ps1`: first generation failed because FindMPI's guessed additional include path polluted exported interfaces with the source root (`no-parmetis-mfem.log`). Explicit SDK additional include paths resolve it. Next compilation (`no-parmetis-mfem-sdk.log`) exposed Japanese-code-page parsing of Unicode comments in hyperbolic.hpp and missing /EHsc after overriding flags. /utf-8 and /EHsc resolved these without modifying the hyperbolic implementation (`no-parmetis-mfem-utf8.log`, native build/install passed). Consumer test reproduced the encoding error (`mfem-connection.log`), so a small MFEM CMake patch exports those flags and generates MFEM_DEBUG consistently for assertions-enabled Release. Rebuilt/installed successfully (`no-parmetis-mfem-exported-flags.log`). Next experiment: run the MFEM connection test against the exported target.

Additional Gate 2 executable work: extracted official, vendor-hash-verified dpcpp_impl_win-64 2025.3.0 intel_640 into the same repository-local compiler tree (`icx-extract.log`). Its C99 frontend is needed by libCEED's existing variable-length arrays; C++/Fortran remain cl/ifx. `icx-cl.exe --version` now runs without the earlier missing-frontend error (`icx-complete-version.log`). This is a build-only supplement, not a system install or claim of a complete conda environment. Core library tags were resolved to commits and fetched from their upstream repositories (`core-fetch.log`, per-library fetch logs); all are locked. Raw logs in this entry are under `.work/gate2/` unless otherwise stated.

### No-ParMETIS connections passed; native Palace compilation started

`test-mfem.ps1` passed using the installed exported target (`mfem-connection-exported-flags.log`). One-rank ParMesh/assembly with 16 true DOFs; MUMPS PORD/METIS residual L2 3.19867e-17/2.30137e-17; Hypre PCG residual 1.69967e-17. Fixed pre-run limits were 1e-10 + 1e-10 times RHS/exact norm. Explicit PARMETIS raised the required diagnostic and was caught/checked. ParaView Save produced files; independent viewer validation remains open. `test-no-parmetis.ps1` extended to newly installed PARPACK also passed all four tests (`no-parmetis-tests-parpack.log`). `build-arpack-windows.ps1` installed native libraries and repeated the scoped ten serial upstream tests, all passed (`no-parmetis-arpack.log`); multi-rank tests remain unexecuted.

`build-libceed.ps1`: native IntelLLVM C99 static build with four standard CPU backends passed 17 tests (`libceed-windows.log`). Windows allocation adapter retains 64-byte alignment and correctly frees/reallocates both aligned allocations and caller-owned ordinary CRT pointers. After retaining alignment in registry entries instead of assuming it, tests passed again (`libceed-alignment-field.log`). Palace's actual MSVC header/link probe exposed GNU `__restrict__` spelling; export a compiler-specific equivalent `__restrict` definition, preserving the qualifier. All 17 tests passed after that interface change (`libceed-msvc-interface.log`).

`build-core-libs.ps1`: JSON/schema-validator/fmt/scn built and installed. Eigen 5's top-level default started its unused BLAS/LAPACK builds; stopped only our identified cmake build process tree (PID 21832) and selected header-only Eigen explicitly, retaining oneMKL as the only math implementation. The corrected recipe completed (`windows-core-libs-header-eigen.log`). This was not a failing numerical-test workaround.

`audit-no-parmetis.ps1 -Executable <mfem-connection.exe>` inspected ten then-installed static libraries and exported CMake dependency files: no vendor ParMETIS implementation symbols or artifact dependencies (`no-parmetis-audit/report.json`). MUMPS-owned disabled-feature wrapper names are distinguished from third-party implementation symbols. `audit-runtime.ps1` recorded eight executable/runtime files and twenty Windows imports (`runtime-audit/closure.json`); dynamic loading and clean-host proof remain pending. Immutable connection evidence is `docs/evidence/G2-no-parmetis-connections-2026-09-17.json`.

`build-palace-windows.ps1` now configures the actual inner Palace target with the native installed stack and no ParMETIS. After the libCEED header fix, compilation exposed implicit filesystem-path-to-string conversion and LLP64 std::distance/std::max mismatches (`palace-native-restrict.log`). Preserved paths as filesystem::path and used the actual difference type for max. Next compile exposed the same path assumption in the CSV wrapper (`palace-native-path-width.log`); adapted its native path storage/streams while preserving UTF-8 diagnostic strings and CSV formatting. Compilation continues (`palace-native-csv-path.log`). A Windows memory-reporting port uses real working-set APIs and 64-bit byte counters rather than 32-bit Windows long. These ports are under validation, not a Palace success claim.

### Native Palace portability follow-ups

Pushed connection checkpoint 2cd12d5. Subsequent native compilation found only narrowly identifiable portability failures so far:

- `palace-native-csv-path.log`: two local floating-point constants needed explicit lambda captures; retained their values/checks.
- `palace-native-lambda.log`: made the driven ParaView member-template instantiation's existing template argument explicit.
- `palace-native-template.log`: replaced path-to-string assumptions at ParaView and MFEM string-only APIs with UTF-8 conversions and explicit optional emplacement.
- `palace-native-paraview-path.log`: MSVC's legacy lambda processor mishandled a nested init-capture in RomOperator. Selected `/Zc:lambda` (documented in ABI_CONTRACT.md), preserving the source/algorithm. This caused a deliberate rebuild, log `palace-native-standard-lambda.log`; the nested-lambda source then compiled.
- That build reached a template-parameter name collision with inherited mfem::Coefficient. Renamed only the three Restricted* template parameters. An over-broad draft rename was caught immediately (`palace-native-coefficient-name.log`) and restricted to those template definitions; `palace-native-coefficient-scope.log` is the corrected attempt. No algorithm, tolerance or assertion was removed.

Windows memory accounting now uses the real process working-set APIs and 64-bit byte quantities. Added a process-local UTF-8 manifest, not a system-locale change, and native palace.exe naming. The Unicode application-path claim remains untested until the executable runs. Fixed Gate 2 smoke cases are prepared by `tools/prepare_windows_smoke.py`: order 1; optional GSLIB probes removed; two lumped driven excitations at one frequency; two lossless basic cavity eigenmodes; original C/L example geometry retained. Original examples are unchanged. These inputs are functionality checks, not a silent replacement for later same-input Linux equivalence. Catch2 v3.8.1 was resolved/fetched at exact commit 2b60af89e23d28eefc081bc930831ee9d45ea58b for upstream test work. `tools/prepare_gate2.py --sources-only` verifies the complete current source patch sets.

### Complete native link and runtime-policy correction

`palace-native-schema-array.log` compiled every Palace translation unit. MSVC's literal size limit required the Windows-only schema emitter to use a byte array; `.work/gate2/schema-byte-equivalence.log` verifies all 126019 original schema bytes (SHA256 cd2c1537ac4fc406de9ed127e5c0587c36b413363a91c9ffc531c97deb023c70). Validation was not removed.

The complete link exposed mixed CRT defaults that the smaller connections had not diagnosed. Older dependency CMake minimum versions ignored CMAKE_MSVC_RUNTIME_LIBRARY without CMP0091 NEW: schema-validator and METIS used /MT, and ARPACK/PARPACK selected Intel static runtimes. Earlier descriptions of these archives as /MD reported the requested configuration, not verified object directives; those descriptions were too strong. Their passing connection results remain valid, but do not prove a consistent runtime family. Added CMAKE_POLICY_DEFAULT_CMP0091=NEW to the shared recipe and rebuilt the affected dependencies. No conflicting-runtime linker suppression was used. `windows-core-libs-crt-policy.log`, `crt-consistent-rebuild.log`, and `archive-crt-directives-corrected.log` record correction, all 4 MUMPS/PARPACK/ifx tests plus the MFEM singleton test passing again, and the actual DLL-runtime directives in every installed dependency archive. Intel libircmt is the compiler support archive, distinct from the forbidden static C/Fortran/math runtime combination.

`build-palace-windows.ps1` then built and installed the complete native executable (`palace-native-consistent-crt.log`). The first actual Electrostatic run selected one MPI rank, CPU host memory and /cpu/self/opt/blocked, then correctly failed on binary Gmsh parsing (`palace-smoke-electrostatic.log`). Investigation found Palace opened the binary mesh in Windows text mode. Changed only the input stream open mode to binary (also valid for ASCII meshes), retaining the original mesh and parser checks; `palace-native-binary-mesh.log` records the next build. Added a Windows exception boundary that reports configuration/runtime errors with nonzero exit rather than an unhandled C++ exception dialog. All logs are under `.work/gate2/`; this developer host is not clean-host deployment evidence.

### Four native Palace solves and actual output validation

After binary mesh input correction, Electrostatic, Magnetostatic, Driven (both excitations), and basic ARPACK Eigenmode returned zero. However, output inspection found MFEM directory warnings and missing VTU files: Palace filesystem paths contained backslashes while MFEM's recursive directory routine splits on forward slashes. Corrected only the two ParaView path conversions to generic UTF-8 paths. `palace-native-paraview-separators.log` records the rebuild. `test-palace-smokes.ps1` repeated all four cases (`palace-smoke-*-final.log`, UTF-16 PowerShell logs), all returned zero. `tools/check_windows_smoke.py` then checked finite CSV/VTU arrays, referenced VTK files, complete 2x2 complex S columns and the original input eigen backward-error tolerance (1e-8). Each case produced five VTU files, including boundary outputs; J_s or its real/imaginary components are present for magnetic/driven/eigen cases. This is structural/data validation, not independent ParaView rendering or Linux numerical equivalence.

`palace-audits-final.log` records static-symbol, export, CRT directive and final link-map inspection plus recursive PE imports. No ParMETIS vendor implementation/artifact found. The developer runtime closure is palace.exe plus seven DLLs: msmpi, libifcoremd, libmmd, svml_dispmd, msvcp140, vcruntime140 and vcruntime140_1. Exact hashes/provenance are recorded separately; Windows OS/API-set imports are not bundled.

Restricted-PATH staging tests also exposed harness issues: PowerShell Start-Process needs a retained process handle for exit-code observation, and its parameterless redirected-stream wait stalled after the solver exited. Stopped only the identified repository test PowerShell processes (1660 and 18624), kept the native logs, and replaced waits with bounded process waits. These harness failures are not clean-host passes. Upstream memory/CSV tests are being built against the actual Palace library with pinned Catch2; a scoped harness avoids claiming the unexecuted full upstream suite.

### Gate 2 completed; Gate 3 reference preparation started

`build-catch2.ps1` initially used Catch2's default C++14 mode, while Palace consumers use C++17; scoped upstream CSV tests exposed the missing string_view printer at link time. Explicit CMAKE_CXX_STANDARD=17 corrected the test dependency, without changing assertions. The harness also required the original PALACE_TEST_DATA_DIR definition. Final `palace-port-tests-cxx17.log`: 11 original Serial test cases / 80 assertions passed. Full upstream and multi-rank suites remain unexecuted.

The final build/run/audit/staging sequence completed in `final-native-validation-streams.log`. A PowerShell wrapper initially treated redirected native CMake warning text as an exception; preserving native streams at the outer shell resolved the wrapper issue without suppressing compiler/test checks. The staged-run harness now uses .NET Process with asynchronous stream draining and bounded waits, avoiding Start-Process redirected-stream waits. It passed with only Windows directories in PATH, Unicode/space executable and working paths, all seven vendor DLLs observed app-local, and nonzero explicit ParMETIS rejection. `tools/check_windows_smoke.py` passed against the final outputs. `docs/evidence/G2-native-2026-09-17.json` pins the executable, runtime and package-member provenance, static/link-map audit, loaded modules, outputs, recipes and log hashes. G2 is passed; G0 remains open; no release was created.

Independent next work: inventoried Linux reference tools (`linux-reference-inventory.json`); gcc/g++/cmake/make exist, Fortran/MPI/container tools do not. Non-elevated `dnf download --resolve --alldeps` with explicit local caches prepared compiler/MPI RPMs; it did not install RPMs or run package scripts. First cache on /mnt/e failed a permission-setting operation; a task-specific /tmp cache worked. ninja-build is unavailable in configured repositories, so use existing make. Verified RPM signatures and extracted 17 selected x86_64 packages under `.work/linux-reference/sysroot`; metadata/hashes in `.work/linux-reference/extracted-packages.json`. GNU Fortran starts. A link probe required the matching system GCC support-directory hints and relocating the extracted libquadmath linker-script path. Native Linux MPI initialization then exposed hard-coded PMIx plugin/data directories, under investigation using package-exposed relocation variables. These are Linux reference preparation attempts, not Windows success claims or numerical comparison passes. Raw logs remain under `.work/gate2/` for this transition.

Linux reference toolchain follow-up: `.work/gate2/linux-reference-probe-pmix.log` records a successful 32-bit-default-integer GNU Fortran/Open MPI singleton after setting process-local PMIX_INSTALL_PREFIX/PMIX_LIBDIR/PMIX_PKGLIBDIR/PMIX_PKGDATADIR to the extracted tree. An unused OpenIB component reports missing libosmcomp and is ignored; the probe itself returns zero. This is not a Palace Linux reference result. OpenBLAS serial/development RPMs were downloaded from configured AlmaLinux repositories with CRB enabled only for that download invocation, not via a persistent repository configuration change (`linux-reference-openblas-download.log`). Reference build scripts, full source-bound Linux build and fixed-tolerance comparisons remain next work. Checkpoint 2695fad was pushed to origin/main; G0 clean-host/offline and redistribution review remain open.

## Gate 3 — matched no-ParMETIS numerical reference

Owner accepted G2's developer-host scope and requested matched no-ParMETIS semantics on Linux. `docs/GATE3_ACCEPTANCE.json` is frozen before any Linux Palace result or cross-platform comparison: complete C/L matrices and trace/norm/quadratic-energy invariants, all complex S entries at 4/5/6 GHz, two sorted complex eigenfrequencies and residual checks. Both inputs, mesh hashes, solver/order/tolerances, singleton/thread settings and output structure are mandatory identities. Field vectors and byte-identical files are not acceptance criteria. Linux will retain the same pinned MFEM/Hypre/METIS/MUMPS/ARPACK/libCEED source versions and no-ParMETIS configuration; compiler/MPI/math platform differences will be recorded. No Windows toolchain/runtime replacement is planned.

Before any Linux Palace solve, clarified the structural criterion for the derived quality factor: Q may be infinite only when the imaginary eigenfrequency is exactly zero (lossless mode); compared eigenfrequencies/residuals and all field data must remain finite. No numerical acceptance tolerance changed. Input manifests were regenerated with the updated acceptance hash; configuration/mesh bytes are unchanged from the completed Windows Gate 3 run.

Linux reference preparation/build uses `scripts/build-linux-reference.sh` and process-local `scripts/linux-reference-env.sh`. The isolated Palace source receives the exact Windows source overlays plus a reference-only patch removing the platform gate and selecting native Linux pkg-config for libCEED; solver behavior is unchanged. ARPACK receives the same three Palace patches plus upstream's GNU-only timing patch. MPI/Hypre/METIS/MUMPS/PARPACK interfaces stay LP64. Numerical libraries differ explicitly: existing Linux OpenBLAS 0.3.29 serial plus upstream-pinned ScaLAPACK 2.2.2 versus Windows oneMKL 2025.3 sequential/LP64 and MS-MPI BLACS. METIS and ScaLAPACK built successfully (`.work/gate3/linux-metis.log`, `linux-scalapack.log`). The remaining component sequence is running in `linux-build-sequence.log`, with one heavyweight build at a time. Native Windows Gate 3 runs finished with the same frozen inputs (`windows-run.log`). No equivalence assessment has run.

Read-only redistribution investigation continues while Linux builds. Exact MPI/Intel accompanying license texts and Microsoft's official VC runtime/Build Tools license documents were retrieved under `.work/licensing/`. Microsoft's VC Runtime use license does not grant redistribution by itself; the official VS redistribution list conditions distribution on the relevant VS license. Requested the owner's entitlement category asynchronously (no key requested), while continuing engineering. Intel DLLs are named in fredist and covered by the accompanying EULA's conditional product-redistribution grant; downstream terms, liability clauses and notices must be included. MUMPS 5.7.3 is CeCILL-C, PORD's bundled README identifies public-domain SPACE code, and Eigen is MPL-2.0: packaging must preserve notices and provide the covered source, not just a binary file list. No redistributable-package declaration has been made.

Linux MUMPS connection validation (`scripts/test-linux-mumps.sh`, `.work/gate3/linux-mumps-connections.log`) passed both existing PORD and METIS solves, with INFOG(7)=4/5 and zero residual under the unchanged Gate 1 tolerance. The optional OpenIB transport reports an unavailable hardware-support library and is ignored by Open MPI; the singleton solves pass. No need to chase non-V1 transport dependencies. Hypre is building next. `tools/prepare_linux_reference.py --verify` passed exact RPM/source/patch identity checks; package URLs and hashes are locked for the comparison environment. It uses extraction only, never a system package install.

Fresh `Get-ExecutionPolicy -List` output is `.work/gate3/powershell-policy.txt`; all five scopes remain Undefined. Only the previously authorized process-scoped PowerShell route was used. `docs/evidence/G3-inputs-2026-09-17.json` records identical input identities and the executed Windows candidate, not a Linux equivalence pass.

Redistribution/source-closure audit found scn's existing fetched header dependency fast_float was absent from the earlier top-level lock. The validated Windows build contains fast_float v6.1.6 at 00c8c7b0d5c722d2212568d915a39ea73b08b973. Added this exact existing commit to the lock and pointed both recipes at its prepared source; this does not replace a dependency or alter the Windows binary. Preserve its Apache/Boost/MIT license choices and authors with package notices. This closes a real transitive-provenance gap; G2's executed tests remain unchanged. Linux build parallelism for subsequent components is four jobs after confirming 14+ GiB available memory; numerical runs remain one thread and one rank.

### Gate 3 continuation: driver recovery and RF export

The first Linux sequence completed Hypre compilation but stopped before installation with a Bash EOF/quote diagnostic. The driver had been edited while Bash was reading it (parallelism and fast_float pin); the resulting file passes `bash -n`. Restarted the sequence at Hypre with `for component in hypre mfem arpack ceed core palace; do bash scripts/build-linux-reference.sh "$component" ...; done`, process-local reference environment, logs `.work/gate3/linux-<component>.log`. Hypre installed and MFEM compilation started. No numerical criteria or dependency versions changed. Do not edit a script while its process is still reading it.

Implemented the V1-required Touchstone 1.x exporter (`src/sparams`, native MSVC C++17 /MD) using the existing toolchain. Command: `tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File scripts\build-sparams.ps1`; log `.work/gate3/sparams-build.log`. Five native executable tests passed via `python3 -m unittest discover -s tests/numerics -p test_sparams.py`, log `.work/gate3/sparams-tests.log`: complex phase and 11/21/12/22 order, reversed port mapping, s1p, Unicode/space paths, existing-output protection, missing/nonfinite rejection, and every frequency/complex entry of the Windows Gate 3 driven CSV. Python is developer-only; the shipped utility uses the already required VC runtime. Reference impedance is explicitly asserted by the caller and is not silently renormalized. Linux numerical equivalence is still unassessed.

The Linux MFEM connection passed on the matching LP64 reference: PORD residual 3.29141e-17, METIS residual 4.6158e-17, Hypre/PCG residual 0; the explicit ParMETIS rejection was observed. Command: source `scripts/linux-reference-env.sh`, configure/build `tests/mfem` in `.work/linux-reference/build/connections/mfem`, then `ctest --output-on-failure`. Log `.work/gate3/linux-mfem-connection.log`, detailed output in that build's `Testing/Temporary/LastTest.log`. This validates the reference connection, not Palace equivalence. Optional unused OpenIB transport reports missing libibumad; singleton tests continue successfully, so no transport dependency is being added.

Exporter recursive PE audit passed using `scripts/audit-runtime.ps1 -Executable .work/build/sparams/palace-sparams.exe -OutputDirectory .work/gate3/sparams-runtime-audit`: executable plus the same three VC runtime DLLs; no new runtime family. Clean-host runner syntax was parsed successfully by native PowerShell, but it has not run on an independent host. Staging recipe is prepared with a numerical-comparison prerequisite; no package or redistribution pass has been declared.

The Linux reference Palace executable linked and installed successfully (`.work/linux-reference/build/palace/palace-x86_64.bin`, build log `.work/gate3/linux-palace.log`). The locked dependency sequence completed without system installation. `bash scripts/test-linux-connections.sh` also passed PARPACK mode 1 (max residual 6.87413e-14) and shift-invert mode 3 (7.12383e-13), preserving the original test limits. Started `bash scripts/run-gate3-linux.sh` for the four identical cases and `python3 tools/audit_linux_reference.py` in the reference environment. Logs `.work/gate3/linux-run.log` and `.work/gate3/linux-identity-audit.log`. Numerical comparison is not yet assessed at this entry.

### Gate 3 passed; enter Gate 4

`python3 tools/compare_gate3.py` passed all 60 predeclared checks, maximum error/allowance ratio 0.000480278 (absolute eigenmode-1 residual difference 4.802780323615e-13 against allowance 1.000000005928e-9). Both complete C/L matrices and invariants, all 12 complex S entries over three frequencies, two complex eigenfrequencies/residuals and both platforms' output structures passed. No limits changed. Linux identity audit inspected 14 archives plus final link map/runtime closure: no ParMETIS artifact. Immutable evidence `docs/evidence/G3-numerics-2026-09-17.json` binds actual source/compiler/math identities, mesh/config hashes, values and log hashes. This passes only the documented developer-host numerical scope. Gate 4 starts immediately; Gate 0 clean-host/offline and redistribution review remain open.

### Gate 4 license interface and candidate revalidation

Added `windows-license-notice.patch`: Windows `--licenses` and its help entry expose MUMPS attribution, CeCILL-C exceptions and bundled source/license locations; no solver logic changed. Applied the same guarded patch to the Linux source and updated its exact prepared-diff identity. Rebuilt Windows via `scripts/build-palace-windows.ps1` and Linux via `cmake --build .work/linux-reference/build/palace --parallel 4`; logs `.work/gate4/*-license-build.log`. Preserved the original numerical outputs under `.work/gate3/{windows,linux}-initial`, reran both platforms' four cases with unchanged inputs, and reran the frozen comparison: all 60 checks passed with the same maximum allowance fraction 0.000480278. `scripts/test-packaging-candidate.ps1` tested `--licenses`/`--help`, repeated Windows no-ParMETIS/static/runtime audits; 15 Windows archives, the same seven vendor DLLs, no new runtime family. Linux audit again inspected 14 archives and no ParMETIS artifact. `tools/prepare_linux_reference.py --verify` passed. Exact post-change binary/report/lock hashes are in `.work/gate4/candidate-validation.json`. Gate 3's original evidence is retained unchanged.

### Gate 4 exact payload and linked-code license finding

`tools/stage_windows_v1.py` assembled the candidate after post-notice numerical acceptance. `tools/verify_stage.py` verified exact hashes/inventory (nine binaries: two executables and the same seven vendor DLLs). Corresponding source archives contain no .exe/.dll/.lib/.obj/.a/.so filenames. `scripts/test-package-developer.ps1` ran all four cases with restricted PATH and observed every vendor DLL app-local, with output in a whitespace/Unicode directory. The first direct cross-shell invocation lost quoting around the output argument and was rejected before execution; the repository-local wrapper constructs the path natively and passed. Logs `.work/gate4/staged-run.log`, report `.work/gate4/Staged tests 日本語/report.json`. No clean-host claim.

License review traced LGPL-2.1-or-later `GKlib/gk_mksort.h` macros through `libmetis/gklib.c` into `libmetis__ikvsorti/ikvsortd/rkvsortd` in the actual Windows map. The top-level METIS Apache license alone is insufficient. Full source, exact header notices and GNU LGPL-2.1 text are included through `tools/finalize_stage_notices.py`; download identity `.work/licensing/lgpl-source.json`. Static-combination relinking/material and downstream-term obligations remain open, alongside the exact embedded Intel support grant and owner VS entitlement. Do not call source inclusion alone sufficient, or claim package redistribution approval. No dependency/compiler/solver change was made to hide the issue.

### Gate 4 internal candidate prepared; external review blockers

The first Unicode-installation module observation missed msmpi.dll because .NET cached the initial `Process.Modules` collection. The runner now calls `Refresh()` before each sample; requirements were not relaxed. Failed evidence is retained under `.work/gate4/*-attempt1`. Corrected `scripts/test-package-unicode.ps1` passed all four cases with Unicode/space installation and external output paths, restricted PATH, all seven vendor modules observed app-local, native three-frequency complex Touchstone export and explicit ParMETIS rejection. Reassessing those staged outputs against Linux passed all 60 frozen checks with the same maximum allowance fraction. The negative configuration now uses a separate output directory in future runs to preserve positive output evidence.

`tools/verify_stage.py` passed exact 162-file/169,588,994-byte inventory and hashes. `tools/package_windows_v1.py` created `.work/package/palace-windows-1.0.0-internal-validation.zip` (121,760,427 bytes; SHA256 9305a0883ffc29c35fbb7459b8b1409573cea59ee147b2cf34972397d7a6fb9c). ZIP CRC/unique-path/traversal checks passed. Separate diagnostics ZIP contains the actual link map; no PDB was produced by the validated Release recipe. Internal payload is unsigned, has no installer/service/system-runtime action, and includes source, notices, manifest, examples and the independent test kit. Evidence: `docs/evidence/G4-internal-candidate-2026-09-17.json`.

Stopping at genuine external licensing/host blockers, not marking readiness: owner VS entitlement fact is unanswered; exact embedded Intel compiler-support redistribution coverage is not established; static LGPL/GKlib relinking/terms review depends on a defensible complete proprietary/open-source distribution route; an independent standard-user offline clean-Windows host is unavailable. Gate 0 remains open, Gate 4 is blocked despite the complete internal payload, Gate 5 is unexecuted/blocked, and fresh-cache Gate 6 reproduction/final Gate 7 review are not passed. No release, tag, policy persistence, elevation, compiler/solver swap or ParMETIS approval request occurred. Next discriminating actions are recorded in STATE and the exact-payload review.

### Owner Visual Studio entitlement confirmation

The owner confirmed Visual Studio Community with eligibility confirmed. Recorded the exact attestation in `docs/evidence/VC-owner-entitlement-2026-09-17.json` and removed the missing-entitlement fact from active blockers. Updated the review and next-package notice wording. This does not substitute for applicable distributable-code conditions, close Intel/GKlib review, or pass clean-host testing. Existing candidate ZIP, manifest and historical evidence remain unchanged to preserve their hashes. Documentation/state validation passed; no binary rebuild or numerical rerun was needed for this owner fact.

## 2026-09-17 — Exact redistribution closure investigation; original ZIP preserved

Scope: same Windows developer host, MSVC 19.44.35219 / ifx 2025.3.0 (20251010), Palace b92aef83ecfe6d360c4b3d83e2122986297f6778, pinned no-ParMETIS sources, one rank/thread. No elevation, system installation, new solver/compiler, public release/tag, or subagent. `Get-ExecutionPolicy -List` recorded to `.work/redistribution/execution-policy.txt`: MachinePolicy/UserPolicy/CurrentUser/LocalMachine Undefined, Process Bypass in the authorized process. Builds use `cmd.exe /d /c '<repo>\tools\native-dev.cmd powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...'`. Existing ZIP SHA256 remains `9305a0883ffc29c35fbb7459b8b1409573cea59ee147b2cf34972397d7a6fb9c`; no new stage/ZIP was created.

1. `python3 tools/audit_intel_redistribution.py` verifies locked archives and exact selected member bytes for seven Intel packages, preserving the old map/executable/cache under `.work/redistribution/pre-link/`. Output: `intel-package-audit-final.log`, `intel-package-audit.json`; sanitized structured evidence `docs/evidence/G4-intel-package-2026-09-17.json`. Exact 2025.3 fredist SHA256 `93f11995a945f987d9e23aabb61122bfb6ddf3fe413c7f157a78362db29dff4c`, accompanying August 2024 EULA SHA256 `4e96f3006c9d51b38561f9802da896480dc48e7703a76c206292bf6d6d11a781`. The fredist introduction's April 2023 reference is recorded, not silently corrected. libircmt is unlisted; nine original objects are identified. DLL imports and incorporated oneMKL objects are distinguished explicitly.

2. `.work/redistribution/inspect-intel.ps1` inspected libircmt/libircmd/libircdisp symbols. Adding listed libraries without excluding the libircmt default did not remove its objects (`listed-intel-link-recipe.log`). An initial configure omitted the common MPI cache arguments and started unnecessary recompilation; only that owned build process tree was stopped, common arguments restored, and affected objects rebuilt. A direct PowerShell attempt without native-dev failed to find CMake and made no build change (`explicit-intel-link.log` was subsequently used for the successful native-dev route). The discriminating link uses `/NODEFAULTLIB:libircmt.lib` plus exact libircmd.lib/libircdisp.lib, not broad CRT suppression. It linked with no unresolved symbols and no libircmt objects. libircdisp contributes no live code; libircmd.dll supplies the two required memory-operation imports. Persistent Palace recipe now selects this route and fails on any static Intel/METIS implementation found in its final map.

3. Pinned METIS has no sort-exclusion option. Existing `SHARED=ON` initially emitted no import library because `_WINDLL` was missing; adding the upstream API declaration define passed the METIS connection test (`metis-shared-exports.log`). Palace then exposed missing uppercase Fortran wrappers (`shared-palace-link.log`, two unresolved symbols). Exporting existing `METIS_SETDEFAULTOPTIONS` and `METIS_NODEND` resolved this; no algorithm changes. Exact flags: /O2, /MD, `/D_WINDLL`, ASSERT/ASSERT2 ON, 32-bit idx_t/real_t, `/EXPORT:METIS_SETDEFAULTOPTIONS /EXPORT:METIS_NODEND`. Logs `metis-shared-fortran-exports.log`, `shared-palace-fortran-link.log`. Persistent no-ParMETIS recipe and connection-DLL staging updated. This is LGPL retention, not a permissive relabeling. The map records three live LGPL macro-instantiated sorting functions and retained LGPL getopt/regex data. Full corresponding source/notices/build/replacement instructions and executable GNU attribution are prepared.

4. The first working shared-METIS/listed-Intel closure passed four native solvers and all 60 frozen Gate 3 comparisons (`numerics/comparison.json`). After the GNU UI notice, `build-final-link.ps1` invokes the persistent Palace build recipe; `final-audit.ps1` recursively audits ten PE files (Palace plus nine DLLs), and logs `--licenses`. `scripts/test-staged-package.ps1` against the isolated `.work/redistribution/app-local` engineering fixture passed all four cases with restricted PATH and all nine modules app-local. `tools.compare_gate3`, with BASE set to `.work/redistribution/final-numerics`, passed all 60 checks against the unchanged Linux reference. Max error/allowance stays 0.000480278. Inputs, explicit ordering, solver semantics and acceptance criteria were unchanged. Neither fixture is a candidate package or clean-host evidence.

5. For LGPL 6(b), copied the pinned METIS source to `metis-replacement-source`, added only a diagnostic fprintf in METIS_SetDefaultOptions, rebuilt with the same shared ABI (`build-replacement-metis.ps1`, `metis-replacement-build.log`). Replaced only metis.dll beside the identical Palace executable in `replacement-app-local`. The same four-case app-local harness passed; diagnostic markers prove use of the modified DLL in cases invoking METIS. All 60 comparisons passed again (`replacement-numerics/comparison.json`). Modified probe source/DLL are not selected for shipment. MUMPS PORD/METIS, PARPACK, mixed ifx/MSVC runtime and one-rank parallel MFEM connections also passed (`connection-regression.log`); standalone METIS connection passed. Full final identities, live LGPL entries, original ZIP preservation, imports and comparisons are in `docs/evidence/G4-redistribution-linkage-2026-09-17.json`. Both DLL/executable maps exclude ParMETIS implementation; Palace contains no static METIS or libircmt objects.

6. Read the exact MPI SDK EULA as well as the runtime EULA: SDK 2(a)(i) covers binary/header distribution and the actual mpifbind.obj. Downloaded official Community 2022 DOCX, current 2022 REDIST page and Microsoft licensing guidance; hashed exact files, SDK notices, VC startup archives, runtime file/product versions and installed STL header SPDX samples (`audit-vc.ps1`, `version-inventory.ps1`). Community eligibility remains owner-confirmed. `docs/evidence/G4-microsoft-terms-2026-09-17.json` and the single 28-component redistribution matrix record actual grants, required downstream terms and notices. Notice assembly now includes both MPI EULAs/TPNs and STL/Community evidence. No package was mutated.

7. Source verification exposed pre-existing batch reverse-check sensitivity to overlapping Palace patches. The added GNU notice was consolidated into the existing notice patch; all local patch hashes are now locked, including the previously omitted notice patch hash. `tools/prepare_gate2.py` now checks ordered patches on isolated copies and only copies a complete successful forward application into the real tree. Failed experiments are in `source-verification*.log`. `--sources-only` now passes (`source-verification-isolated.log`); two meaningful regression tests cover overlapping-patch idempotence and preserving the original after a later patch fails (`patch-sequence-tests.log`). Python syntax checks and state-structure validation pass. No source-preparation failure is hidden as a license pass.

Remaining external blocker: LGPL 2.1 section 6's combined-work modification/debugging condition versus Intel Developer Tools EULA 2.1.D(2) and the oneMKL October 2022 prohibition is not resolved by the supplied texts. Shared-library replacement has been demonstrated but cannot itself grant rights in Intel's proprietary code. `RUNTIME_TERMS.txt` is a concrete review draft; matrix statuses explicitly retain that unresolved interaction and package-fulfillment requirements. Next discriminating action is a qualified compatibility determination for this exact separation/wording or applicable rights-holder permission. No vendor communication has been sent. Staging now fails closed on an unresolved matrix; historical notice-refresh entry point refuses in-place candidate mutation. Do not rebuild/package a new candidate before closure.

Independent standard-user offline Windows access/evidence is still absent. The future clean-host protocol explicitly requires all three path classes, four solvers, output structure/numerics, nine app-local DLLs, repeated/failure/recovery runs and network/system-change observations. No clean-host kit is represented as complete or passed. Gates 0/4/5 remain open, 1/2/3 retain their accepted developer scopes, and G6/G7 remain unexecuted.

## 2026-09-17 — Owner authorizes engineering continuation with one legal review pending

Owner direction supersedes the prior packaging hold. Started `tools/reproduce_windows_v1.py --destination .work/reproduction/r1`: fresh repository/source trees, freshly extracted compiler/numerical packages and SDK, empty build/install directories; reused only SHA256-verified download archives. Sources fetched at pins from upstream; no old generated libraries/objects/cache copied. Initial native build found the missing x64 SDK installation alias `mpifptr.h`, previously restored by the Gate 1 script. Bootstrap now copies exact `mpifptr64.h` bytes to that alias. Preserved first failed build/install trees and restarted with empty build/install directories. Logs `.work/redistribution/fresh-reproduction.log` and `fresh-build-sdk-layout.log`. No compiler, numerical implementation or ABI change.

Fresh policy/host-tool query recorded `.work/redistribution/release-host-inventory.txt`: all execution-policy scopes Undefined outside the authorized Bypass process. No discovered Get-VM/VBoxManage/vmrun command supplied a configured independent clean host. Asked for independent host/tester access while continuing autonomous engineering; no clean-host evidence fabricated.

## 2026-09-17 — Fresh-cache recipe repairs and developer deployment checks

The owner confirms no independently prepared clean Windows environment is
available. Gate 5 and the clean-host portion of Gate 0 remain blocked. No
new request for that same access is needed.

Fresh build r1 (initial recipe 83b6474) reached MFEM with empty caches and
exposed its finder early-return behavior when INCLUDE_DIRS was already set.
The persistent build-mfem.ps1 now supplies complete HYPRE_LIBRARIES and
MUMPS_LIBRARIES matching the previously validated cache, including explicit
MS-MPI/ifx dependencies. Preserved the failed MFEM directory and configured a
new empty one. Native resume command: r1/tools/native-dev.cmd powershell.exe
-NoProfile -ExecutionPolicy Bypass -File
.work/redistribution/resume-fresh-build.ps1. Build/connection log:
.work/redistribution/fresh-build-explicit-mfem.log. Fresh Palace, exporter,
four ABI/ordering connections, one-rank MFEM and 80 assertions in 11 Palace
port tests passed. The separate fresh no-ParMETIS audit passed 15 libraries.
Fresh isolated four-case numerical validation is recorded separately.

The preview shared-METIS payload passed 24 solver executions across ASCII,
whitespace and Japanese paths, six negative-input/unsupported-ParMETIS tests,
repeat/recovery, CSV/VTU structure and Touchstone export. All six run sets
passed the unchanged 60-check Linux comparison (360 total). Instrumented
repeat observed every non-system runtime app-locally, but the default MS-MPI
singleton opened a TCP listener on 0.0.0.0. Logs and results:
.work/redistribution/path-suite-observed-review2.log and
.work/gate5-comparisons/observed/summary.json. These are developer-only tests.

Microsoft's pinned options source documents process-local MSMPI_DISABLE_SOCK
and MSMPI_DISABLE_ND. A separate four-case test with both set to 1 observed
no TCP endpoints and passed all 60 fixed comparisons. Provenance and logs:
.work/redistribution/msmpi-options-source.json, network-transport-check.log,
.work/network-transport-check/comparison.json. Adopted only this one-rank
launcher policy; MPI remains enabled, and no toolchain, solver, Windows
security or persistent environment setting changed. The final kit samples
all modules/TCP endpoints and rejects any observed endpoint under this policy.
Sampling does not prove absence of transient network attempts; independent
offline/network evidence is still required.

Source/notice assembly now uses deterministic corresponding-source archive
metadata and includes the Windows resource/build overlay directory. The new
review2 candidate is distinct from the preserved historical ZIP. Its pre-ZIP
finalizer verifies unchanged binary identities and refuses a frozen ZIP.

Fresh isolated numerical validation passed all 60 unchanged Linux comparisons,
with valid CSV/VTU output and all nine app-local vendor DLLs. Exact rebuilt
PE/runtime hashes, source heads/diffs, recipes, maps and logs are recorded in
docs/evidence/G6-fresh-reproduction-2026-09-17.json. Palace and METIS PE bytes
differ from the candidate; vendor runtime DLLs match exactly. This is source
and recipe reproduction with tested numerical equivalence, not a claim of
bit-identical PE output.

A final-kit test was launched before staging finalization had finished; its
inventory check correctly failed on CLEAN_HOST_TEST.md before solver work.
Preserved path-suite-final-kit-review2.log; the final suite uses a new output
root only after finalizer and inventory verification complete. A separate
launcher test exposed cmd.exe argument parsing with a slash-mixed executable
path in ProcessStartInfo. Using Join-Path with native backslashes fixed it:
launcher-quoting-check2.log and launcher-report.json show successful driven
execution with Japanese/space configuration name and nonzero missing-input
failure. No Palace solver change.

## 2026-09-17 — Internal review2 frozen; independent execution/legal blockers only

Final staged kit execution command: powershell.exe -NoProfile -ExecutionPolicy
Bypass -File <review2>/Test-Paths.ps1 -PackageDirectory <review2> -OutputRoot
.work/gate5-final-kit-v2-review2 -DeveloperHost. The exact finalized staged
scripts passed 24 native solver runs (four cases, twice, in each of ASCII,
whitespace and Japanese application/work/output paths), six missing-input or
unsupported-ParMETIS failures, three Touchstone exports, and three launcher
success/missing-input pairs with Japanese/space configuration filenames.
All observed vendor DLLs were app-local, all other loaded DLLs were Windows
system modules, and no process-owned TCP endpoint was sampled under the
explicit process-local socket/ND-disable policy. CSV/VTU structures passed.
The unchanged Linux-reference acceptance criteria passed 360 complete-case
checks plus 36 launcher complex-S checks. No thresholds were changed.
Evidence: docs/evidence/G5-prepared-kit-2026-09-17.json; raw log:
.work/redistribution/path-suite-final-kit-v2-review2.log. These are explicitly
developer-host results and do not pass Gate 5.

Commands tools/finalize_review_payload.py, tools/verify_stage.py and
 tools/package_windows_v1.py produced the distinct exact review2 internal
candidate. Frozen ZIP: .work/package/palace-windows-1.0.0-review2-internal.zip,
150838953 bytes, SHA256
6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2.
All 191 staged files (200018936 bytes) have recorded hashes; every ZIP member
matches the staging manifest, no extra members exist, and ZIP CRC verification
passed. The separate 2118014-byte diagnostics ZIP contains both linker maps;
no PDB was generated by this Release recipe. The original candidate remains
byte-identical at SHA256
9305a0883ffc29c35fbb7459b8b1409573cea59ee147b2cf34972397d7a6fb9c.
No frozen ZIP has been modified after creation.

All 28 component rows are COMPONENT_REVIEW_COMPLETE and exact package
fulfillment is MECHANICALLY_COMPLETE. Only LGPL_INTEL_COMBINED_WORK remains
LEGAL_REVIEW_PENDING. This is neither a compatibility conclusion nor public
redistribution approval. The replaceable shared-METIS architecture and its
prior modified-DLL validation remain intact. No compiler, solver, numerical
library or toolchain was changed to speculate around the legal issue.

Gate 4 packaging engineering and Gate 6 fresh-cache reproduction now pass in
their documented scopes. Gates 0/5 remain blocked on the unavailable independent
standard-user offline Windows environment. Gate 7 remains blocked on the
single qualified legal determination. State validation passes; --ready
correctly fails on exactly Gates 0, 5 and 7 and the non-ready project status.
Tooling verification passed 2 patch-sequence tests, 14 readiness tests and
8 numerical-tool tests. Top-level unittest discovery found no tests, so the
actual test subdirectories were invoked explicitly; no zero-test run is
counted as validation. Git diff whitespace check passes.

The handoff is docs/RELEASE_REVIEW.md, with artifact hashes, scope, signature
status, evidence links and the two external next actions. No public release
or tag was created. Next discriminating evidence requires an independently
prepared clean host and qualified review of the exact LGPL/Intel question;
repeating developer-host runs cannot supply either.
