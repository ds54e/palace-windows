# Agent instructions

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

Parent default: Terra/medium. Do not change the running parent's model, user subscription, or global configuration autonomously. Optional delegation must follow `docs/CODEX_OPERATIONS.md`; verify local CLI support and actual child model before relying on it. No recursive subagents or nested `codex exec` orchestration. No Astra, Max/Ultra, or premium speed tier without user authorization.

One writer and one heavyweight build at a time. Read-only children return bounded evidence; the parent applies patches and validates. Model-budget counts persist across sessions in `docs/STATE.json`. AGENTS instructions are policy, not a hard billing or OS security boundary.

## Evidence and handoff

For each substantive attempt, record command, source/build identity, environment scope, outcome, relevant log path, and the next discriminating experiment in `docs/DEVLOG.md`. Keep raw logs in `.work/`; inspect bounded error excerpts rather than repeatedly loading full logs. Sanitize logs before committing excerpts.

Update state at meaningful gate transitions and before context reset. A clean build, a passing local smoke test, numerical equivalence, and clean-machine deployment are distinct claims. Use absolute-plus-relative numerical tolerances fixed before assessing the candidate. Never silently widen them after failure.

Do not stop after writing plans while executable work is available. If blocked on host access, privilege, licensing evidence, quota, or model availability, record the precise blocker and continue independent in-scope work. Do not repeatedly retry without new evidence.
