# Gate 0 native functional result

The owner authorized process-scoped PowerShell execution-policy bypass for repository build/test scripts. MachinePolicy and UserPolicy were both Undefined before execution. The other three scopes were also Undefined. The same output was observed in a fresh process after testing. No persistent policy, registry, Group Policy, service, installation, or security-feature change was made.

`tools/windows.sh` now passes `-ExecutionPolicy Bypass` only to its allowlisted repository script process. Organizational policy retains precedence. The doctor's VS inventory needed a Windows PowerShell 5.1 array-enumeration correction; after that correction it correctly reported Build Tools 17.14.36623.8.

## Results

- Native Windows x64 probe compiled, linked, and executed successfully with Microsoft MPI 10.1.12498.18.
- All probe checks passed, with rank 0, size 1 and the loaded MPI DLL inside the staged application directory.
- The wrapper cleared the inherited environment and supplied its restricted PATH. No system MPI indicators or matching services were detected; process was non-elevated.
- The initial dynamic-CRT executable imported centrally available VC runtime DLLs. Rebuilt only the probe using CMake MSVC_RUNTIME_LIBRARY=MultiThreaded for Release. Its direct imports are now msmpi.dll and KERNEL32.dll. This does not select the future Palace ABI/CRT configuration.
- The MPI DLL directly imports KERNEL32, ADVAPI32, RPCRT4, WS2_32, MSWSOCK, ntdll, NTDSAPI and AUTHZ. This static import inspection is not a complete observation of dynamically loaded modules.
- Repeated the static-CRT probe from `.work/staging/MPI 空白 probe`; functional and app-local checks passed.
- Both final wrapper results are `functional_only` (wrapper exit contract 2). Neither clean-host attestation nor offline evidence was supplied. Gate 0 remains blocked on these external tests and final redistribution compliance review.

## Acquisition and reproduction

Exact download URLs, input/output hashes, source hashes and payload sizes are in `G0-payload-2026-09-17.json`. Download with `curl -fsSL URL -o FILE` to `.work/downloads/`. Verify hashes before extraction. The native installed 7-Zip 22.00 x64 was used only as a local extraction tool; neither MPI installer was executed.

1. Extract SDK: `7z.exe x -y -o<repo>/.work/extracted/sdk <repo>/.work/downloads/msmpisdk.msi` using native Windows paths.
2. The exact pinned runtime EXE contains Compound File MSI signatures at byte offsets 110592 and 3449344. A local Python byte search for `d0cf11e0a1b11ae1` wrote each suffix to an intermediate MSI. Extracting the first finds only x86; extracting the second with `7z.exe x -y` to `.work/extracted/runtime-x64` exposes both architectures. These offsets apply only to the hashed installer, not arbitrary versions.
3. Select `msmpi64.dll` (PE32+ x86-64), not `msmpi.dll` (PE32 x86). Stage the former under the loader name `msmpi.dll`, byte-for-byte unchanged. Retain the accompanying EULA and third-party notices. SDK import library is `msmpi64.lib`.
4. Initialize installed `VC/Auxiliary/Build/vcvars64.bat` from a native cmd process. Run `powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File <repo>/scripts/build-gate0.ps1 -MpiIncludeDir <repo>/.work/extracted/sdk -MpiLibrary <repo>/.work/extracted/sdk/msmpi64.lib -Generator "Visual Studio 17 2022"`, using native paths. Compiler identified itself as MSVC 19.44.35219.0, with SDK 10.0.22621.0.
5. Copy `.work/build/gate0/Release/mpi-singleton.exe` beside the staged DLL and notices. Run `bash tools/windows.sh run-gate0 -ProbeExe '<native absolute probe path>'`. Do not pass CleanHostAttested for this developer machine.
6. Audit both PE files using installed x64 `dumpbin.exe /dependents`. This is import metadata inspection, not disassembly.

Authenticode reported Valid with Microsoft Corporation as signer for the downloaded runtime installer, SDK MSI, and extracted x64 MPI DLL. DLL version is 10.1.12498.18. These checks establish acquisition evidence, not numerical validation or legal approval.

## Redistribution findings

The exact runtime EULA's section 1 permits Windows application use. Section 2 describes binary distribution rights with application-functionality, downstream-terms and other obligations. The SDK has corresponding development/test and distribution terms. This resolves the earlier absence of version-specific binary terms; it does not mean the release packaging has fulfilled them. The runtime is not being relicensed under the repository's Apache-2.0 license. Preserve both vendor license and third-party notices. Release review must address downstream terms, notices, applicable obligations, and the static VC runtime as well as all future dependencies.

The EULA and notices are retained with the local payload; their exact hashes are committed in the manifest. No vendor binary is committed or published.

## Raw evidence

Local logs: `.work/inventory/execution-policy-authorized.txt`, `execution-policy-after.txt`, `doctor-authorized.log`, `extract-setup.log`, `extract-sdk.log`, `extract-x64.log`, `setup-list.txt`, `signature.txt`, `payload-signatures.json`, `build-gate0.log`, `build-gate0-static.log`, `imports.txt`, `imports-static.txt`, `run-gate0.log`, `run-gate0-static.log`, and `run-gate0-unicode.log`. The first signature-query attempt had a PowerShell pipeline parse error; the corrected query produced the recorded JSON. No payload was modified by that query.

Raw run directories: `.work/gate0/83283bafd36044bcabe4e9149f13655e` (dynamic CRT), `.work/gate0/0942a44a5f96453898d4306413f9b5ce` (static CRT), and `.work/gate0/9ab6493b614d40dfb38069de5a7bb8b0` (Unicode path). Sanitized final reports accompany this document. UTC timestamps are September 16; the local session date in Japan is September 17.

## Next discriminating experiment

Copy the exact hashed probe payload and repository runner into an independently prepared Windows 11 x64 clean environment. Use a true standard-user account, with no system MPI/VC/Intel runtime or SDK; disconnect networking independently and document that preparation. Run the same wrapper and preserve the loaded-module path, exit code, hashes and preparation evidence. Only the operator who verified those conditions may use CleanHostAttested. This developer machine cannot supply that evidence, and owner provisioning may require privileges outside current authority.
