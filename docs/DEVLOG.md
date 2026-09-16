# Engineering log

## 2026-09-16 — Repository preparation

Observed the private repository containing only its initial README. Prepared the V1 contract, bounded Codex model policy, optional configuration templates, source pin, native MPI probe source, Windows diagnostics, and release-readiness tooling.

No local Windows host was accessed. No Palace build, MPI runtime test, clean-Windows test, or numerical validation has passed. Optional Codex child templates have not been activated on the user's CLI. See the preparation report for checks actually run on the preparation environment.

## 2026-09-17 — Model policy simplified

Changed the default Codex parent from Terra/medium to Astra/low by owner decision. Sol/medium is now the owner-controlled cost/quota fallback parent, Luna/medium remains an optional bounded read-only helper, and Terra is removed from the default V1 path. Removed the automatic Sol/high specialist route to keep model routing simple and avoid turning routing into project work. Higher Astra effort still requires explicit owner authorization.

This policy change does not alter any Palace build, runtime, numerical, or release-readiness status. Gate 0 remains not run.

For subsequent entries use: gate/blocker; hypothesis; exact command; source/toolchain identity; result; evidence path/hash; next experiment. Keep full raw logs in `.work/` and commit only sanitized evidence.
