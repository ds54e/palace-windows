# Gate 0: administrator-free MPI singleton

## Question

Can the intended Windows MPI runtime, with a valid redistribution route, run natively from an application directory on a clean standard-user machine without MPI installation, a service, or `mpiexec`?

This is unverified. Merely installing MS-MPI on the developer machine and running one rank does not answer it.

## Probe supplied here

`tests/runtime/mpi_singleton.cpp` initializes MPI, checks rank=0/size=1, duplicates a communicator, checks collectives, performs a self-send using a derived datatype, and finalizes. It emits JSON and, on Windows, the loaded `msmpi.dll` path. The CMake target supports a directly supplied MPI header/import library pair; it does not download or install an MPI runtime.

Use a developer toolchain already authorized by the owner. Supply artifacts with recorded provenance; do not extract a DLL from a third-party installer and assume its redistribution is allowed.

Example from a native Windows developer shell:

```powershell
.\scripts\build-gate0.ps1 -MpiIncludeDir 'E:\deps\mpi\include' -MpiLibrary 'E:\deps\mpi\lib\msmpi.lib'
```

Stage `mpi-singleton.exe` with only its explicitly allowed runtime files in a dedicated directory. Keep a list of every payload file, hash, source, license/re-distribution evidence, and link mode. Do not collect arbitrary DLLs from System32.

Run the diagnostic wrapper:

```powershell
.\scripts\run-gate0.ps1 -ProbeExe 'E:\staging\mpi-probe\mpi-singleton.exe'
```

The wrapper strips the normal PATH, constrains math threads to one, checks common system MPI indicators and elevation, captures output with a timeout, and records a report under `.work/gate0/`. It does not change machine settings. Detection is a limited check, not proof that a host is clean. It currently targets the MS-MPI candidate.

## Required evidence levels

1. Native Windows functional test: PE executable completes and reports expected MPI results.
2. Application-local loading: the actually loaded MPI DLL is inside the staged application directory, including correct handling of directory boundaries.
3. Isolated standard-user test: system MPI absent, no service needed, non-admin account, ordinary PATH without SDKs, no UAC, offline execution.
4. Provenance/redistribution review: distribution route is documented for exactly the staged bytes.

`-CleanHostAttested` may be supplied only by an operator who has independently prepared and checked a clean VM/Sandbox environment. It is an attestation, not a bypass. A Windows CI runner full of SDKs is not a clean host. Provisioning the VM itself may require the owner's admin action; running the final package inside it must not.

Even a positive wrapper result is called `candidate_pass`, not a passed Palace build or a redistribution approval. Store sanitized reports/hashes as evidence only after review; raw reports may contain local paths and remain ignored by Git.

## Failure routing

Classify the first failure: PE/architecture, dependency loading, MPI initialization, service/registry use, collective behavior, exit/finalization, or redistribution. Keep the exact command, import list, module paths, and relevant error. One parent experiment changes one variable. Use the bounded specialist envelope rather than repeatedly rebuilding the entire application.

If runtime deployment fails, do not silently replace this requirement with a system installer, WSL, or a custom MPI shim. Record the blocker and investigate the smallest established alternative.
