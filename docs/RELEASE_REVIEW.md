# Internal release-engineering handoff

Status: **READY_FOR_OWNER_USE_CLEAN_TEST_DEFERRED**. This is not
`READY_FOR_RELEASE_REVIEW`.

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

The owner has deferred independent clean-Windows testing. Gate 0 and Gate 5
remain unpassed, and portability to an independently prepared standard-user
offline host remains unverified. The deferral does not block personal use on
the currently validated developer host. Do not start or request VM, ISO,
Hyper-V, VMware or alternate-host preparation unless the owner explicitly
resumes that work. The all-gates readiness check remains unchanged and must
continue to reject `READY_FOR_RELEASE_REVIEW`.

`OWNER-HOST_SMOKE_TEST: PASS` is recorded for the exact frozen package. The
documented owner-use procedure completed without exceptions, all four packaged
examples returned exit code 0, and the expected scalar, field and ParaView
outputs were manually inspected. This result is bound in
[the owner-host evidence](evidence/OWNER-HOST-smoke-2026-09-18.json). It is not
an independent clean-host or portability result and does not change Gate 0 or
Gate 5.

The exact Windows path to the frozen owner-use ZIP is:

`E:\projects\palace-windows\.work\package\palace-windows-1.0.0-metis-remediation-review1-internal.zip`

SHA256: `09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2`

The following PowerShell commands verify the ZIP, refuse to overwrite existing
installation or result directories, extract under the current user's local
application-data directory, copy each example into a separate Documents result
tree, and run it through the packaged launcher:

```powershell
$zip = 'E:\projects\palace-windows\.work\package\palace-windows-1.0.0-metis-remediation-review1-internal.zip'
$expected = '09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2'
$actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actual -ne $expected) { throw "ZIP hash mismatch: $actual" }

$install = Join-Path $env:LOCALAPPDATA 'Palace\1.0.0-metis-remediation-owner'
$results = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Palace owner results\metis-remediation-review1'
if (Test-Path -LiteralPath $install) { throw "Installation path already exists: $install" }
if (Test-Path -LiteralPath $results) { throw "Results path already exists: $results" }

Expand-Archive -LiteralPath $zip -DestinationPath $install
New-Item -ItemType Directory -Path $results | Out-Null
$launcher = Join-Path $install 'Run-Palace.cmd'

foreach ($case in 'electrostatic','magnetostatic','driven','eigenmode') {
    $work = Join-Path $results $case
    Copy-Item -LiteralPath (Join-Path $install "examples\$case") -Destination $work -Recurse
    Push-Location $work
    try {
        & $launcher config.json *> run.log
        if ($LASTEXITCODE -ne 0) { throw "$case failed with exit code $LASTEXITCODE" }
    }
    finally {
        Pop-Location
    }
}
```

Inputs and generated outputs remain under the separate `$results` tree. Removing
`$install` later does not delete those results. Choose new directory names for a
second installation or run; do not remove an existing directory unless its
contents have been reviewed and intentionally preserved elsewhere.

Do not change either frozen ZIP in place, publish a release or create a tag. A
changed payload needs a new candidate identity and validation binding. No public
release or tag has been created.
