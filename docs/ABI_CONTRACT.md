# Windows V1 candidate ABI contract

This is the developer-host Gate 1 contract, not a completed dependency lock or deployment approval. The owner authorized continued Gate 1/2 engineering while Gate 0 clean-host and redistribution items remain open.

## Selected path

Retain MSVC C/C++, Intel LLVM Fortran (ifx), Microsoft MPI, Intel oneMKL, parallel MUMPS, and ARPACK-NG/PARPACK. This follows the demonstrated Windows compiler/math-library family described by [WelSim](https://github.com/WelSimLLC/WelSim-Apps/discussions/145), while retaining the actual dependencies and patches pinned by Palace v0.18.0. WelSim's older Palace version and serial MUMPS settings are not evidence for this complete stack.

Installed MSVC is 19.44.35219.0 (tool directory 14.44.35207), VS Build Tools 17.14.36623.8, SDK 10.0.22621.0. The repository-local Intel compiler candidate is ifx 2025.3.0 build 20251010. Intel's [compatibility table](https://www.intel.com/content/www/us/en/developer/articles/reference-implementation/intel-compilers-compatibility-with-microsoft-visual-studio-and-xcode.html) lists 17.14.18 for the 2025.3 compiler family; the installed 17.14.19 is a nearby patch, and compatibility must be established by our executed tests. It is not an exact vendor-certified pairing claim.

The [Intel compiler download page](https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler-download.html) documents a Windows compiler package. Hash-verified Intel channel packages are extracted under `.work/deps/intel`; no oneAPI system installer, registry registration or elevated action is used. The full downloaded compiler is a developer tool and must not be put in the end-user package.

[Intel's oneMKL download page](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-download.html) documents the static and cluster NuGet packages. Candidate oneMKL 2025.3.0.453 uses `mkl_intel_lp64`, `mkl_sequential`, `mkl_core`; cluster calls use `mkl_scalapack_lp64` and **`mkl_blacs_msmpi_lp64`**, never Intel-MPI BLACS with MS-MPI. This selection favors the proven Windows library family, not dependency minimization.

## Interface requirements

| Boundary | Required contract |
| --- | --- |
| Native architecture | PE x64; pointers and size_t 64 bits; Windows LLP64 (`int` and `long` 32 bits) |
| C/C++ | MSVC, C linkage for interlanguage exports; C++17 minimum for tests |
| Fortran scalar integers | Default INTEGER and ISO_C_BINDING C_INT 32 bits; no `/integer-size:64`, `-i8`, or equivalent |
| Fortran logical | 32 bits; consistent `/fpscomp:logicals` for MUMPS and consumers; validate PARPACK logical arguments through its ICB entry points |
| Fortran real/complex | DOUBLE PRECISION / C_DOUBLE 64 bits; C_DOUBLE_COMPLEX and std::complex<double> occupy 16 bytes; complex return ABI must be executed, not assumed from size |
| MPI | MS-MPI 10.1.12498.18; MPI_Comm/MPI_Fint 32 bits, MPI_Aint/MPI_Count 64 bits; convert communicator with MPI_Comm_c2f |
| Fortran MPI | SDK mpif.h plus byte-identical mpifptr64.h under installed name mpifptr.h; msmpifec64.lib and msmpi64.lib; CHARACTER length at end, cdecl; no CVF calling-convention override |
| BLAS/LAPACK | LP64 numerical interface: MKL_INT 32 bits, despite native Windows LLP64; no MKL_ILP64 define; explicitly select LP64 library |
| ARPACK/PARPACK | Palace commit 804fa3149a0f773064198a8e883bd021832157ca; ICB=ON, MPI=ON, INTERFACE64=OFF; a_int 32 bits; preserve Palace patches |
| MUMPS | Wrapper 1cfd19699702f9a64ff5d45827d6025ff5c3873a / upstream 5.7.3; MUMPS_parallel=ON, intsize64=OFF, double-real arithmetic as Palace selects; preserve Palace patch |
| CRT | Gate 1 candidate uses release DLL CRT (`/MD`, Fortran `/libs:dll`); dependencies statically archived where selected. App-local VC/Intel runtime closure remains mandatory before shipping. Gate 0's independent `/MT` probe does not set this contract. |
| Threads | Sequential MKL and OpenMP off for first connection tests; one process, thread environment fixed to one. No permanent single-thread claim. |

The initial MUMPS connection solve uses PORD ordering; METIS/ParMETIS integration in Palace's full recipe remains pending. No automatic switch to serial MUMPS or replacement MPI is permitted. We will not claim the first small solve validates untested orderings or thread configurations.

## Tests and fixed acceptance criteria

`tests/abi` crosses actual C/C++/Fortran object boundaries, exercises CBLAS real/complex operations, Fortran LAPACK and complex-return BLAS, C-to-Fortran MPI communicator use, collectives, and Fortran CHARACTER MPI calls. A successful configure alone does not pass these tests.

Before execution, the connection and MUMPS checks use absolute-plus-relative tolerances of 1e-12 + 1e-12 times the documented reference magnitude. Complex dot checks use absolute 1e-12. PARPACK tests use six complex diagonal entries, checking both regular mode and shift-invert mode with non-real sigma; each eigenvalue and normalized residual must satisfy 1e-10 + 1e-10 times its reference/eigenvalue magnitude. Inputs and criteria are in the test source. Non-finite results fail. No tolerance may be widened silently.

Build commands from WSL after `python3 tools/prepare_gate1.py` and the recorded Gate 0 SDK/payload preparation:

```text
cmd.exe /d /c '<native repo path>\tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <native repo path>\scripts\build-gate1.ps1'
cmd.exe /d /c '<native repo path>\tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <native repo path>\scripts\build-gate1-solvers.ps1'
cmd.exe /d /c '<native repo path>\tools\native-dev.cmd powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <native repo path>\scripts\build-gate1.ps1 -Solvers'
```

Run commands through the batch wrapper so environment changes expire with that process. All build/download outputs are local and ignored. Tests here are developer-host evidence; they do not establish clean-host independence, numerical equivalence of Palace, or release readiness.
