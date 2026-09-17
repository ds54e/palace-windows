# Decisions

## D001 — Convenience first (accepted user requirement)

Native Windows x64, administrator-free end-user use, portable or per-user deployment, and no development tools required. First intended public distribution release: V1.0. Public publication remains owner-controlled.

## D002 — Conservative execution baseline

One CPU rank and one thread establish reproducibility. Threads may be enabled after validation without changing the installation contract. One process is not synonymous with one core or an inherent 4 GB memory ceiling. Distributed ranks on one host still share that host's RAM budget.

## D003 — Runtime before full build

MS-MPI application-local singleton is a candidate, not a proven solution. Test runtime and redistribution separately before investing in Palace's full dependency stack. No custom MPI implementation by default.

## D004 — Upstream pin

Palace v0.18.0, commit b92aef83ecfe6d360c4b3d83e2122986297f6778, was resolved from the official release/tag API on 2026-09-16. Dependency/toolchain pins still require local investigation. Do not promise compatibility from a version label.

## D005 — Astra-low parent with a simple cost fallback

Astra/low is the default parent for V1 because the project is long-horizon, multi-step Windows portability work where avoiding repeated failed attempts matters more than minimizing per-token price. Sol/medium is the owner-authorized cost/quota fallback parent. Luna/medium may be used only for bounded read-only extraction or factual surveys. Terra is not part of the default V1 path. Higher Astra effort requires explicit owner authorization. Model routing must remain simple and must not become a project deliverable.

## D006 — Evidence before labels

Preparation, developer-host success, clean-host success, numerical validation, and release readiness are separate states. Python bootstrap checks do not validate Windows MPI or Palace. A readiness file cannot prove its own factual claims.

## D007 — Preserve host policy and separate compilation evidence

The first real host rejected PowerShell scripts under Restricted policy. Do not add an execution-policy bypass to the bridge. Native read-only commands and a compile-only MSVC probe established useful facts independently. A compiled object and a singleton source branch do not pass Gate 0. Vendor installer redistribution statements do not establish extracted-DLL redistribution rights.

## D008 — Owner-authorized process policy and probe CRT

The owner superseded D007's prohibition on a process-only bypass: repository build/test PowerShell processes may use `-ExecutionPolicy Bypass`, after recording scopes, without persistent policy changes or circumvention of organizational policy. MachinePolicy/UserPolicy were Undefined and the authorized route succeeded. Organizational policy still takes precedence.

Use static MSVC CRT for the Gate 0 probe so its success does not rely on centrally installed VC runtime DLLs. This choice does not freeze the Palace dependency ABI. Native singleton/app-local success is established on the developer host only; clean standard-user/offline acceptance remains external.

## D009 — Continue build engineering while deployment review stays open

Owner explicitly accepts G0 native singleton evidence as a functional prerequisite for G1/G2, without marking G0 fully passed. Clean standard-user/offline testing and redistribution review remain mandatory release gates. Use the developer-host validated MSVC/ifx/MS-MPI/oneMKL LP64 path; do not replace it for dependency minimization. G1's first MUMPS solve uses parallel MUMPS with PORD; integrate Palace's METIS/ParMETIS recipe during G2. ABI and source/package identities are recorded in `docs/ABI_CONTRACT.md` and `deps/gate1-lock.json`.

## D010 — MPI-enabled Windows V1 without ParMETIS (2026-09-17)

Owner explicitly selected a no-ParMETIS variant; obtaining ParMETIS redistribution approval is outside the V1 critical path. Preserve the pinned license evidence. Use MPI + Hypre + METIS + MUMPS PORD/METIS + ARPACK/PARPACK. Retain Palace's enum/API spelling and reject explicit unsupported ordering rather than substitute silently. Keep changes in a Windows build overlay and a narrowly guarded MFEM wrapper check; do not replace MPI or rewrite Palace solvers. Multi-rank scaling and ParMETIS ordering are not V1 requirements. See `NO_PARMETIS.md` for the dependency trace and validation status.

## D011 — Frozen numerical reference and internal package boundary (2026-09-17)

Gate 3 compares the pinned no-ParMETIS variant with identical meshes/configurations, one rank/thread, explicit solver/ordering and predeclared tolerances. All 60 scalar/matrix/complex-frequency/residual checks passed; raw field equality is not required. Retain the validated dynamic Windows runtime stack. The native Touchstone utility shares its VC runtime closure.

Gate 4 produces an exact unsigned internal candidate, not a public release or redistribution approval. Corresponding MUMPS/Eigen and other open-source snapshots/notices accompany it. Actual linked GKlib LGPL sorting code means METIS's top-level Apache license is not the complete license picture. Do not conceal that finding, infer Intel static-support rights from generic deployment guidance, or infer VC distribution entitlement from an installed Build Tools directory. Close these concrete obligations and independent clean-host/offline evidence before release readiness. No ParMETIS approval returns to the critical path.

## D012 — Redistribution-driven runtime linkage (2026-09-17)

Keep MSVC/ifx, MPI, oneMKL, MUMPS and all numerical algorithms unchanged. The exact Intel 2025.3 `fredist.txt` does not establish redistribution coverage for `libircmt.lib`, although it names `libircmd.dll`, `libircmd.lib` and `libircdisp.lib`. Select the listed import libraries and exclude only the `libircmt.lib` default-library directive. Unresolved symbols still fail the link; assertions, tests and CRT diagnostics remain enabled. Final map and four-solver tests must demonstrate the replacement; generic Intel static-deployment documentation is not treated as an overriding grant.

Use pinned METIS's existing `SHARED=ON` route and `_WINDLL` exports, adding exports for its existing `METIS_SETDEFAULTOPTIONS` and `METIS_NODEND` Fortran wrappers. Retain the LGPL implementation and fulfill source, notice, modification/debugging and replaceable-library requirements. There is no pinned configuration that removes `GK_MKQSORT`; do not claim Apache-only licensing or introduce a rewritten sort. A permissive external sorting library would change implementation and require a separately sourced port; it is unnecessary for this existing shared-library compliance route. Record all linked LGPL code/data, including unused-source data retained by the shared-library link, and test replacement without relinking Palace. Existing ZIP remains immutable while review is open.

## D013 — Separate final legal review from release engineering (2026-09-17)

By explicit owner direction, the LGPL/Intel combined-work question remains one final `LEGAL_REVIEW_PENDING` item, not an engineering gate preventing internal package construction, clean-host validation or fresh-cache reproduction. Preserve the tested shared-METIS design and Intel/compiler/solver choices. Do not conclude legal compatibility or incompatibility. Already reviewed component grants stay closed; package fulfillment is checked mechanically. Keep the historical ZIP immutable and use a new candidate name/hash. Clean-host access/evidence is a separate factual requirement and cannot be replaced by a developer-host run.
