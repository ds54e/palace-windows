# Internal release-engineering handoff

Status: **BLOCKED_EXTERNAL_CLEAN_HOST**. Not READY_FOR_RELEASE_REVIEW.

The distinct unsigned METIS-remediated candidate is
`.work/package/palace-windows-1.0.0-metis-remediation-review1-internal.zip`
(150,698,765 bytes; staged payload 199,921,056 bytes across 194 files).

SHA256: `09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2`

The frozen review2 ZIP remains byte-identical at SHA256
`6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2`.
It is historical evidence and retains its historical legal-review status. It
was not relabeled, modified or replaced in place.

The new candidate keeps PETSc METIS commit
`08c3082720ff9114b8e3cbaa4484a26739cd7d2d` and backports only the attributed
Apache-2.0 standard-library sorting/exclusion prior art from NetworkX-METIS
commit `26a51ddad5932d843655e5b7ba1225bcfe3b8882`. The shared ABI, Intel/MSVC
toolchain, MPI, BLAS, MUMPS, ARPACK/PARPACK and solver behavior remain the
validated Windows V1 stack.

The final Windows source and link audit found no compiled or linked GKlib
`sort.c`, `getopt.c` or `gkregex.c`, no old `GK_MKQSORT` instantiations and no
ParMETIS vendor symbol or artifact. Selected final sort functions are attributed
to `gklib_sort.cc.obj`, including the inlined C++ standard-library sort code.
The Linux archive/map gives the corresponding `gklib_sort.cc.o` attribution.
Excluded LGPL source remains in the corresponding-source bundle with its own
license and notices.

Focused METIS tests passed 2/2; PORD, METIS ordering, PARPACK and mixed
ifx/MSVC connection tests passed 4/4. The final Windows candidate passed all
four required solver cases, app-local module observation, CSV/VTU validation
and the unchanged 60/60 Linux numerical comparisons. Maximum error was
0.000480278 of the allowed tolerance. The exact staged payload was then run
again for all four cases and its output checks passed.

The package matrix has 28 complete component records and exact package
fulfillment. For these new artifact hashes, the former
`LGPL_INTEL_COMBINED_WORK` question is recorded as
`RESOLVED_BY_COMPONENT_REPLACEMENT`. This records removal of the identified
implementation and is not an opinion about the old shared-METIS/Intel
combination. Evidence is in
[the remediation record](evidence/LEGAL-metis-remediation-2026-09-18.json) and
[the exact matrix](packaging/REDISTRIBUTION_MATRIX_METIS_REMEDIATED.json).

One external action remains: supply an independently prepared Windows 11 x64
standard-user environment with no development tools, installed MPI/Intel
runtime, Visual Studio, Python, WSL or network dependency. Read-only discovery
found the current Windows 11 Home host has no supported Hyper-V VM role or
management plane. Provide a Windows 11 Pro or Enterprise host with Hyper-V
already enabled and accessible, then execute the prescribed ASCII, whitespace,
Japanese/Unicode, four-solver, repeated-run, failure-path, app-local runtime and
offline checks against the frozen new ZIP. Gates 0 and 5 remain open; no clean-
host result is inferred from developer-host tests.

Do not change either frozen ZIP in place, publish a release or create a tag. A
changed payload needs a new candidate identity and validation binding. No public
release or tag has been created.
