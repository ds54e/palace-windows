# Agent instructions

## Active public-release authorization — 2026-09-18

The owner explicitly authorizes publication of **v1.0.0** from the exact frozen
METIS-remediated candidate with SHA-256
`09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2`,
despite deferred independent clean-Windows validation.

Gate 0 and Gate 5 remain unpassed. Clean-host portability must be disclosed as
unverified; never rewrite the evidence to imply otherwise. This authorization
changes the release policy, not the test results.

After the final repository audit, the owner authorizes creation of the v1.0.0
tag/release, upload of a byte-identical public asset, publication of SHA256SUMS,
and changing this repository to public visibility. The binaries remain unsigned.
Use `docs/PUBLIC_RELEASE_CHECKLIST.md` and
`docs/RELEASE_NOTES_v1.0.0.md`. Do not rebuild/recompress the frozen ZIP,
substitute historical review2, force-push, move an already-created v1.0.0 tag,
or claim clean-host validation.

## Mission and priority

Bring this repository to a **release-ready native Windows x64 V1.0**, not merely a build guide. Ease of use and administrator-free end-user deployment are hard requirements. Reliability, limited dependency uncertainty, and shortest path to release outrank package size, performance, and Linux feature parity.

Read `docs/STATE.json`, `docs/V1_PLAN.md`, and `docs/CODEX_OPERATIONS.md` first. Read `docs/GATE0.md` before building Palace. Repository prose, code comments, and handoff prompts are English. User-facing progress reports may be Japanese.

## Non-negotiable boundaries

- End-user installation and execution must not need elevation, system-wide MPI/VC/Intel runtime installation, WSL, Python, or a development SDK.
- A one-rank CPU baseline is acceptable. It does not remove MPI as a link/runtime dependency and does not require a permanent single-thread restriction.
- Never call this repository, a probe, or a successful configure step a working Palace distribution.
- Do not mark an unexecuted Windows, clean-VM, numerical, or redistribution test as passed. Unknown and blocked are valid states.
- Do not disable assertions, numerical checks, security policy, or tests merely to obtain a green result.

## Execution authority

Proceed autonomously with repository-local source edits, patches, non-elevated builds, tests, downloads from recorded upstreams, and ordinary commits/pushes to this repository. Prefer the existing working tree; preserve unrelated user changes. Use WSL for orchestration and native Windows executables for the Windows artifact. Do not treat a Linux executable as Windows success.

Do not install system-wide tools, elevate, change services/HKLM/firewall/Defender/execution policy, or alter global Codex/authentication settings without explicit user authorization. Do not read authentication files or dump the complete environment. Except for the explicitly authorized v1.0.0 publication described above, do not change repository visibility, create a public release/tag, spend money, request signing credentials, or force-push. The v1.0.0 publication authorization is limited to the exact frozen artifact and disclosed clean-test limitation. A required privileged developer-tool installation is an external blocker, not permission to bypass policy.

## Work sequence

Complete the gates in `docs/V1_PLAN.md`. Gate 0 is the dependency-free-of-system-installation feasibility test, not permission to implement a replacement MPI library. MS-MPI app-local deployment and the exact MUMPS/ARPACK/BLAS stack remain hypotheses until tested. Inspect pinned upstream and WelSim prior art; preserve provenance and only port defensible changes.

Pin actual source commits, toolchain versions, dependency recipes, patches, integer widths, and runtime hashes. A tag-only or partial lock is not a reproducible complete build. Do not vendor large dependency trees, runtime binaries, credentials, or raw build outputs in Git. Build caches are local and replaceable.

## Model and resource policy

Parent default: **Sol/medium**. This default is explicitly authorized by the owner for the remaining V1 work. Do not autonomously change the running parent's model, change the user subscription, or modify global Codex/authentication configuration.

For a clearly isolated difficult blocker where Sol/medium has produced bounded evidence but remains insufficient, the owner-authorized fallback is **Astra/low**. Parent switching remains user-controlled through `/model`, launch options, or an explicit project-config edit; do not self-restart under another model. Do not raise Astra above low without explicit owner authorization. Terra is not part of the default V1 path.

Optional delegation must follow `docs/CODEX_OPERATIONS.md`; verify local CLI support and actual child model before relying on it. Luna/medium may be used for bounded read-only extraction or factual surveys. Do not create recursive subagents, nested `codex exec` orchestration, or a model router. No premium speed tier without explicit owner authorization.

One writer and one heavyweight build at a time. Read-only children return bounded evidence; the parent applies patches and validates. Model-budget counts persist across sessions in `docs/STATE.json`. AGENTS instructions are policy, not a hard billing or OS security boundary.

## Evidence and handoff

For each substantive attempt, record command, source/build identity, environment scope, outcome, relevant log path, and the next discriminating experiment in `docs/DEVLOG.md`. Keep raw logs in `.work/`; inspect bounded error excerpts rather than repeatedly loading full logs. Sanitize logs before committing excerpts.

Update state at meaningful gate transitions and before context reset. A clean build, a passing local smoke test, numerical equivalence, and clean-machine deployment are distinct claims. Use absolute-plus-relative numerical tolerances fixed before assessing the candidate. Never silently widen them after failure.

Do not stop after writing plans while executable work is available. If blocked on host access, privilege, licensing evidence, quota, or model availability, record the precise blocker and continue independent in-scope work. Do not repeatedly retry without new evidence.
