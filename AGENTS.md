# Agent instructions

## Active status override — 2026-09-18

The owner accepts the scoped METIS/GKlib remediation for the distinct new
candidate as `RESOLVED_BY_COMPONENT_REPLACEMENT` at the exact recorded hashes.
Do not reinterpret the frozen review2 candidate as cleared. Preserve both frozen
ZIPs and all historical evidence; do not rebuild or regenerate either artifact
for documentation-only work.

The current project status is `READY_FOR_OWNER_USE_CLEAN_TEST_DEFERRED`.
Independent clean-Windows testing is deferred by owner decision, remains
unexecuted, and Gate 0/Gate 5 remain unpassed. Clean-host portability is still
unverified, but this does not block personal use on the validated developer
host. Do not initiate, prepare, or repeatedly request a VM, ISO, Hyper-V, VMware,
or alternate clean host unless the owner explicitly resumes that work.

Continue on the review branch and do not merge main, publish packages, or create
tags/releases. The all-gates `READY_FOR_RELEASE_REVIEW` contract remains
unchanged; owner-use status must not be treated as release readiness.

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

Do not install system-wide tools, elevate, change services/HKLM/firewall/Defender/execution policy, or alter global Codex/authentication settings without explicit user authorization. Do not read authentication files or dump the complete environment. Do not change repository visibility, create a public release/tag, spend money, request signing credentials, or force-push. Prepare release artifacts and stop at `READY_FOR_RELEASE_REVIEW`; publication needs owner action. A required privileged developer-tool installation is an external blocker, not permission to bypass policy.

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
