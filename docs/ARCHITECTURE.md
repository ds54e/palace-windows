# Architecture and host boundaries

## Development

Use one canonical checkout on a Windows drive, for example `E:\projects\palace-windows` / `/mnt/e/projects/palace-windows`. WSL Codex edits and orchestrates; Windows CMake, compiler, linker, and test executables produce/validate PE x64 binaries. Keep Windows and Linux build directories separate. Do not use the same CMake cache across operating systems.

`tools/windows.sh` converts only its selected repository script path using `wslpath`. Additional path arguments must already be Windows paths. It calls PowerShell without changing execution policy, preserves the process exit code, and allows only repository scripts named in its allowlist. It is a convenience wrapper, not a security sandbox.

The development host may need compilers that require an owner-approved installation. That does not relax the administrator-free requirement for the distributed application.

## Runtime candidate

A thin native launcher may launch `palace-core.exe` from the package's own runtime directory. Use deterministic, restricted DLL loading and explicit working directories. Keep user models and outputs out of the installation tree. Do not depend on the current directory or a machine-wide PATH to find numerical libraries.

First investigate an application-local MPI singleton with no launcher/service dependency. Do not infer feasibility from a `--serial` launcher option or a runtime's open-source license. Track separately: source buildability, runtime behavior, clean-host behavior, and redistribution rights.

Keep one MPI ABI across Palace/MFEM/Hypre/MUMPS/PARPACK. Record BLAS interface integer width, MPI Fortran bindings, compiler runtimes, and link modes. Prefer one known-working configuration over a matrix of optional backends.

## Practical fallback order

1. Test a properly sourced, redistributable MS-MPI singleton package.
2. If blocked, identify the exact loader, service, registry, or redistribution dependency before changing strategy.
3. Evaluate another established Windows MPI runtime only with documented provenance and a bounded probe.
4. Do not begin a custom MPI shim or broad MPI removal by default. Record the scope and ask the owner before committing to that redesign.

Administrator-free is not permission to bypass enterprise application control. Offline local execution does not guarantee every corporate endpoint permits an unsigned application.

## Scope of preparation

The repository currently contains operational contracts, diagnostic scripts, an MPI probe, and readiness tooling. It does not yet contain a tested Windows Palace build recipe, a complete dependency lock, a shipping launcher, or licensed runtime payload. Codex should implement these only after the relevant gate has evidence, not fill missing scripts with success-returning placeholders.
