# Palace Windows

Unofficial native Windows x64 distribution work for [Palace](https://github.com/awslabs/palace), focused on simple administrator-free use.

## Download

The first Windows distribution is **v1.0.0**. Download the ZIP from [GitHub Releases](https://github.com/ds54e/palace-windows/releases).

Expected SHA-256 for the v1.0.0 Windows ZIP:

```text
09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2
```

The public asset may be named `palace-windows-1.0.0-win64.zip`; it is a byte-identical copy of the frozen validated candidate.

## What is included

The portable package is designed so a normal Windows user can extract it into a writable directory and run Palace without installing WSL, Python, Visual Studio, Intel oneAPI, system-wide MPI, or a development SDK.

Validated V1 functionality:

- electrostatic capacitance extraction;
- magnetostatic inductance/mutual-inductance extraction;
- driven lumped-port S-parameter analysis;
- basic eigenmode analysis;
- ParaView-compatible field output;
- packaged examples and a Windows launcher;
- app-local runtime deployment;
- no ParMETIS dependency.

CPU / one MPI rank is the V1 baseline.

## Quick start

Extract the release ZIP to a writable directory. The packaged launcher is:

```text
Run-Palace.cmd
```

For example, from a model directory containing `config.json`:

```cmd
C:\path\to\Palace\Run-Palace.cmd config.json
```

The package also contains example inputs for electrostatic, magnetostatic, driven and eigenmode analyses.

## Validation status

The exact packaged candidate passed:

- all four packaged solver examples;
- focused METIS and ABI/solver connection tests;
- CSV/VTU output validation;
- 60/60 fixed Windows/Linux numerical comparisons;
- a separate owner-host smoke test after packaging.

The METIS runtime was remediated so the identified LGPL sorting/getopt/regex implementation is not incorporated into the selected Windows runtime. Exact provenance and redistribution evidence are recorded under `docs/evidence/` and `docs/packaging/`.

### Known limitation: clean-machine validation is deferred

An independent clean standard-user offline Windows machine has **not** been tested yet. Gate 0 and Gate 5 therefore remain unpassed. The release is intentionally being published with that limitation disclosed rather than represented as independently clean-machine verified.

The binaries are also **unsigned**, so Windows or browser reputation warnings may appear.

## Scope

V1 targets Windows 11 x64 and prioritizes a portable, low-friction workstation build. It does not promise GPU support, multi-node MPI, transient analysis, a GUI, mesh/CAD generation, ParMETIS ordering, or Linux feature parity.

## Development

The Windows port keeps upstream Palace pinned and carries narrow Windows/dependency patches plus reproducibility and redistribution evidence.

Start with:

- [V1 plan](docs/V1_PLAN.md)
- [current state](docs/STATE.json)
- [release handoff](docs/RELEASE_REVIEW.md)
- [release notes](docs/RELEASE_NOTES_v1.0.0.md)

```bash
bash tools/windows.sh doctor
```

The repository's own code and build infrastructure are Apache-2.0 licensed. Third-party components retain their respective licenses. Binary packages include the applicable third-party licenses, notices and corresponding-source material required by the recorded redistribution plan.

This project is community-maintained and is not an official AWS Palace distribution.
