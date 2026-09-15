# Palace Windows

Unofficial, convenience-first native Windows x64 distribution project for [Palace](https://github.com/awslabs/palace).

**Status: development preparation only. No Palace executable or verified admin-free MPI package is available in this repository yet.** The first intended public distribution release is **1.0.0**; it is not Palace upstream's version number.

## Product contract

Download a ZIP, extract into a writable folder, and run `palace.exe model.json`. An optional per-user installer must provide the same experience without elevation. No WSL, Python, compiler, system MPI installer, or development SDK is required on the end-user machine. This is a target, not a current capability claim.

Required scope: electrostatic C extraction, magnetostatic L extraction, driven lumped-port S-parameters, basic eigenmodes, and ParaView-compatible fields including the surface-current output needed for GND-return inspection. CPU / one MPI rank is the baseline. Single-thread validation comes first; threads are optional after measurement.

Do not delay 1.0.0 for GPU, transient analysis, multi-node MPI, a GUI, mesh generation, or Linux feature parity. Do not compromise numerical correctness for a smaller installer.

## Start development

Read [AGENTS.md](AGENTS.md), [V1 plan](docs/V1_PLAN.md), [current state](docs/STATE.json), and [Codex kickoff](docs/KICKOFF.md).

Expected workspace: `E:\projects\palace-windows`, also visible as `/mnt/e/projects/palace-windows` in WSL. The actual location is configurable. WSL orchestrates; native Windows tools build and execute Windows binaries.

```bash
bash tools/windows.sh doctor
```

The doctor only inventories the environment and writes a local report. It installs nothing. Scripts may be blocked by host policy; do not weaken that policy automatically.

[Gate 0](docs/GATE0.md) tests whether a legally redistributable, application-local MPI runtime can execute without a system installation. Passing a developer-machine test does not prove clean-machine deployment.

## Repository map

| Path | Purpose |
| --- | --- |
| `docs/` | Scope, decisions, gates, evidence rules, handoff |
| `.codex/config.toml` | Minimal Terra/medium project defaults |
| `config/codex/` | Optional multi-agent templates; not active until verified locally |
| `tests/runtime/` | MPI singleton probe, not an MPI implementation |
| `scripts/` | Native Windows inventory, probe build and execution |
| `tools/` | WSL bridge and release-readiness checks |
| `deps/upstream.json` | Pinned upstream reference, not a complete dependency lock |

Original build infrastructure and probe code are Apache-2.0 licensed. Third-party components retain their own licenses and require separate redistribution review. No third-party binaries are bundled here. See [redistribution checklist](docs/REDISTRIBUTION.md).
