# Internal release-engineering handoff

Status: **BLOCKED_EXTERNAL_CLEAN_HOST_AND_LEGAL_REVIEW**. Not READY_FOR_RELEASE_REVIEW.

The exact unsigned internal candidate is `.work/package/palace-windows-1.0.0-review2-internal.zip`
(150,838,953 bytes; staged payload 200,018,936 bytes).

SHA256: `6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2`

The separate diagnostics archive is `palace-windows-1.0.0-review2-diagnostics.zip`
(SHA256 `42202287c591bba4877f31c7e9ad0d7b897dcf3fd979877ae7b2348a6e19e9dd`). It contains Palace/METIS linker
maps; no PDB was produced by the validated Release recipe. Original candidate
ZIP SHA256 `9305a0883ffc29c35fbb7459b8b1409573cea59ee147b2cf34972397d7a6fb9c` is unchanged.

The frozen staging directory contains Palace, the native Touchstone exporter,
nine app-local DLLs, four pre-meshed solver examples, exact source archives,
licenses/notices, the complete component matrix, manifest and Windows-only
validation kit. Every ZIP member was checked against the staging manifest.
Use Run-Palace.cmd for the tested one-rank process-local MPI transport policy.

Gates 1–3 retain their accepted developer scopes. Gate 4 packaging engineering
and Gate 6 fresh-cache reproduction passed. Final packaged-kit testing on the
existing developer host passed 24 solver runs over ASCII, whitespace and
Japanese paths, 360 fixed full-case comparisons, three launcher runs with
36 complex-S comparisons, repeated execution, six missing-input/unsupported-
ordering failures and three launcher failure checks. CSV/VTU structures are
valid. All nine vendor DLLs were app-local; sampled process TCP endpoints were
empty with the explicit transport policy. Fresh native build tests and all
60 fixed Linux-reference comparisons also passed. Rebuilt Palace/METIS PE
hashes differ and are recorded; vendor runtime hashes match. Byte-identical
reproduction and clean-host/offline operation are not claimed.

Evidence: [frozen package](evidence/G4-frozen-review2-2026-09-17.json),
[developer kit](evidence/G5-prepared-kit-2026-09-17.json),
[fresh reproduction](evidence/G6-fresh-reproduction-2026-09-17.json),
[fixed acceptance criteria](GATE3_ACCEPTANCE.json). Compiler, numerical-library,
solver, ordering and source identities are bound in those records and the
package manifest. The existing dynamic MSVC/ifx/MKL/MS-MPI/shared-METIS stack
and the demonstrated replacement behavior remain unchanged.

Two external actions remain:

1. Supply an independently prepared Windows 11 x64 standard-user environment
   with no development tools, installed MPI/Intel runtime, Visual Studio,
   Python, WSL or network dependency. Read-only discovery on 2026-09-18 found
   that the current Windows 11 Home host has no supported Hyper-V VM role or
   management plane. Provide a Windows 11 Pro or Enterprise host with Hyper-V
   already enabled and accessible to the current account. Then transfer the
   frozen ZIP and follow CLEAN_HOST_TEST.md and
   Test-CleanHost.ps1. Independent extraction, offline execution, interruption,
   cleanup/uninstall and system/network observations must actually execute.
   Gates 0 and 5 remain open.
2. Obtain a qualified determination of the single **LEGAL_REVIEW_PENDING**
   question: Whether LGPL-2.1 section 6's modification/reverse-engineering condition for the combined work is satisfied by the tested replaceable shared-METIS architecture and component-specific downstream terms while Intel's separate proprietary components retain their own reverse-engineering restrictions.
   All 28 component records and package fulfillment are mechanically complete;
   no broader component blocker is asserted. Gate 7 remains open.

Do not change the frozen ZIP in place, declare redistribution approval, publish
a release or create a tag. A changed payload needs a new candidate identity
and validation binding. No public release or tag has been created.
