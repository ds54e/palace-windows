# Palace Windows v1.0.0

First public native Windows x64 distribution of Palace from this project.

## Highlights

- Portable Windows package intended for normal user-space execution.
- Electrostatic capacitance extraction.
- Magnetostatic inductance and mutual-inductance extraction.
- Driven lumped-port S-parameter analysis.
- Basic eigenmode analysis.
- ParaView-compatible field outputs.
- App-local MPI/compiler/runtime dependencies.
- ParMETIS is intentionally not included.
- Packaged examples for all four solver modes.

## Validation

This exact package passed the project's focused dependency/ABI tests, all four solver examples, CSV/VTU checks, 60/60 fixed Windows/Linux numerical comparisons, package-integrity checks and an owner-host smoke test.

The METIS/GKlib runtime path uses an attributed standard-library sorting replacement and excludes the identified old LGPL sorting/getopt/regex implementation from the selected runtime. Detailed evidence and third-party redistribution records are included in the repository and package.

## Important limitation

**Independent clean-machine Windows validation has not yet been performed.**

The package has been exercised on the project owner's validated Windows host, but a separate clean standard-user offline Windows environment has not been tested. This is a known limitation of v1.0.0, not a claim of clean-machine portability.

The binaries are **unsigned**. Windows or browser reputation warnings may therefore appear.

## Baseline and unsupported scope

The V1 baseline is Windows 11 x64, CPU, one MPI rank. GPU support, multi-node MPI, ParMETIS ordering, transient analysis, GUI/CAD generation and full Linux feature parity are outside the v1.0.0 release target.

## SHA-256

```text
palace-windows-1.0.0-win64.zip
09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2
```

This is an unofficial community-maintained Windows distribution project for Palace and is not an official AWS Palace release.
