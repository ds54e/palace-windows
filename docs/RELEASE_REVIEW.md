# Public release handoff

Status: **READY_FOR_PUBLIC_RELEASE_CLEAN_TEST_DEFERRED**.

The owner explicitly authorizes a public **v1.0.0** release of the exact METIS-remediated candidate while independent clean-Windows validation remains deferred. This is an explicit release-policy exception; it does not change Gate 0 or Gate 5 to pass and does not make the strict all-gates readiness check succeed.

## Exact release payload

Frozen candidate:

```text
.work/package/palace-windows-1.0.0-metis-remediation-review1-internal.zip
```

SHA-256:

```text
09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2
```

For the public GitHub asset, a byte-identical copy may be named:

```text
palace-windows-1.0.0-win64.zip
```

The hash must remain identical. Do not rebuild, recompress or otherwise regenerate the frozen ZIP merely to rename the public asset.

Historical review2 remains unchanged at:

```text
6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2
```

Its historical legal-review state is not reinterpreted.

## Validation

For the new candidate:

- focused METIS tests: 2/2 pass;
- PORD / METIS ordering / PARPACK / mixed ifx-MSVC connections: 4/4 pass;
- electrostatic / magnetostatic / driven / eigenmode: pass;
- CSV/VTU checks: pass;
- Windows/Linux fixed comparisons: 60/60 pass;
- maximum fraction of allowed numerical tolerance: 0.000480278;
- exact staged package rerun: four cases pass;
- owner-host packaged ZIP smoke test: pass;
- redistribution matrix: component remediation review complete;
- former LGPL/Intel combined-work issue: `RESOLVED_BY_COMPONENT_REPLACEMENT` for the new exact hashes.

Evidence:

- `docs/evidence/LEGAL-metis-remediation-2026-09-18.json`
- `docs/evidence/OWNER-HOST-smoke-2026-09-18.json`
- `docs/packaging/REDISTRIBUTION_MATRIX_METIS_REMEDIATED.json`

## Deliberately unverified

Independent clean standard-user offline Windows portability remains unverified. Gate 0 and Gate 5 remain unpassed. Do not state or imply that the package has been tested on a clean Windows installation.

The binaries are unsigned.

## Publication policy

The owner authorizes the following for this exact v1.0.0 candidate after the final repository audit:

- create the `v1.0.0` Git tag/release;
- upload the exact frozen ZIP under the public asset name;
- publish a SHA256SUMS file;
- change the repository visibility to public;
- use `docs/RELEASE_NOTES_v1.0.0.md` as the release notes.

Do not substitute review2, rebuild the numerical stack, alter the frozen payload, or claim clean-host validation.

After publication, record the final tag commit, release URL, public asset name/hash and repository visibility in `docs/STATE.json` without moving the v1.0.0 tag.
