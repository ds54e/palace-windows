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
