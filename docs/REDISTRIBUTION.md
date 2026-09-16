# Redistribution review

The original infrastructure and probe code in this repository use Apache-2.0. This does not relicense Palace, numerical libraries, compiler runtimes, Microsoft/Intel binaries, examples, or copied patches.

Before bundling any component, record its exact source/version, artifact hash, whether it is self-built or vendor-supplied, applicable license/redistribution text, required notices, source/patch obligations, runtime dependency closure, and reviewer conclusion. Source licensing and vendor binary redistribution are separate checks. Availability of source does not establish support for application-local deployment.

Do not assume an official installer permits arbitrary DLL extraction and repackaging. Do not copy DLLs from System32 or developer installations without a documented distribution route. Keep complete source provenance for extracted prior-art patches; do not use an unattributed rewrite to evade license obligations.

Do not distribute toolkits, credentials, private simulation geometry, raw user-host logs, or cached proprietary files. Keep the repository private while unresolved third-party assets are reviewed. Automated checks may flag missing records but cannot replace the review.

Maintain a runtime inventory with these fields once actual payloads exist:

```text
relative_path | sha256 | component | version_or_commit | origin
build_recipe | license_id | redistribution_evidence | notices | review_status
```

For release readiness, include the build scripts/patches needed to explain the artifact, license and notice files, supported features, signature status, and reproducible checksums. Do not declare all dependencies permissively licensed until each selected version has been checked.

## Gate 0 payload inventory (developer-host functional evidence)

The exact successful static-CRT payload is `.work/staging/mpi-probe`. All four file sizes and SHA256 hashes, installer URLs/hashes, source hashes, and SDK identities are in [the immutable probe manifest](evidence/G0-payload-2026-09-17.json). Preserve that manifest when creating a future clean-host kit.

| Payload file | Origin / link mode | License evidence | Status |
| --- | --- | --- | --- |
| mpi-singleton.exe | Repository probe, MSVC x64, statically linked release VC CRT; dynamically linked MS-MPI | Repository Apache-2.0; separate Microsoft VC redistributable terms still require review | Native functional test passed; unsigned local test artifact, not Palace |
| msmpi.dll | Official 10.1.12498.18 installer x64 cabinet member msmpi64.dll, renamed without changing bytes | Accompanying Microsoft MPI Redistributable EULA, sections 1 and 2; valid Microsoft Authenticode observed | Exact binary terms located; downstream terms/obligations not yet approved for release |
| MicrosoftMPI_Redistributable_EULA.rtf | Same official runtime installer | Original vendor terms, unmodified | Must accompany review/payload |
| MPI_Redistributables_TPN.txt | Same official runtime installer | Original third-party notices, unmodified | Must accompany review/payload |

No mpiexec, smpd service, launch service, Intel runtime, or separate VC DLL was staged for this successful probe. The import audit lists msmpi.dll and KERNEL32 for the executable, and Windows system DLLs for MS-MPI. This does not prove all dynamic loading behavior on a clean/offline host. Do not copy OS DLLs into a package. The SDK headers/import libraries are build inputs, not probe runtime payloads.

The developer-host path tests passed with spaces and Japanese characters. Clean standard-user/offline operation remains unexecuted. The probe's static CRT does not imply Palace or the Gate 1 mixed-language stack can use the same payload.

## Gate 1 candidate materials

`deps/gate1-lock.json` records exact repository-local compiler/math packages and hashes. Intel compiler packages include an August 2024 Developer Tools EULA, third-party notices and `share/doc/compiler/fredist.txt`; only files covered by applicable redistribution terms may enter the eventual runtime payload. The compiler/toolkit itself stays in the build cache. oneMKL static NuGet packages carry the Intel Simplified Software License (October 2022) and additional notices. These are separate from the MPI license and repository license.

The Gate 1 release-DLL CRT choice requires an independently audited app-local VC/Intel runtime closure. Package-manager dependency lists describe development packages and are not themselves a list of files to ship. Neither the successful Gate 0 probe nor a developer-host ABI test closes that review.

## Gate 2: ParMETIS approval missing

The exact Palace-selected PETSc ParMETIS revision `53c9341b6c1ba876c97567cb52ddfc87c159dc36` contains `LICENSE.txt` with SHA256 `b6dd770c066ee11bc4558e6ccd8913182e79956fca843c94ba7cc6074b7ccc28`. Source origin: https://bitbucket.org/petsc/pkg-parmetis.git . The relevant text is: “The software may not be sold or redistributed without prior approval.” The file also limits unrestricted educational/research use to non-profit institutions and US government agencies, with other organizations limited to evaluation without further approval.

No applicable approval evidence is available in this repository. Treat this dependency as blocked for a distributable payload. Palace v0.18.0 unconditionally finds/links ParMETIS; a no-ParMETIS variant would require explicit source/build changes and validation, not merely omitting a DLL or renaming a library. No ParMETIS artifact has been built or placed in a release payload.

METIS revision `08c3082720ff9114b8e3cbaa4484a26739cd7d2d` is separate: its Apache-2.0 license file hash is `64ab947d7b289ad76e935adff51b31e4ac160df7dfad24480dbaa452e39bbe79`. The native METIS test passed, but that does not resolve ParMETIS permission. Source/license/artifact hashes are in [Gate 2 partial evidence](evidence/G2-partial-2026-09-17.json).

### Owner-selected resolution for Windows V1

D010 removes ParMETIS from the Windows distribution's dependency graph rather than pursuing redistribution approval. The license evidence above remains valid provenance for excluding the upstream-selected dependency. MPI remains enabled; METIS, Hypre, MUMPS PORD/METIS and ARPACK/PARPACK remain selected. This closes the *design decision*, not the final binary audit: build inputs, exported target dependencies, static symbols, link maps and runtime imports must substantiate exclusion in the actual final artifact. No-ParMETIS configuration strings/diagnostics may remain in code without containing the third-party library. See [the overlay trace](NO_PARMETIS.md).

### Native Palace runtime closure (developer candidate)

The complete no-ParMETIS executable has now linked and run all four required solver classes on the developer host. Static archives, exported targets, final link map and PE imports were audited for ParMETIS implementation/artifacts; its enum and explicit unsupported diagnostic remain. No ParMETIS approval is required on this variant's engineering path. Exact artifact hashes are retained in the Gate 2 native evidence.

The observed candidate closure is `palace.exe`, `msmpi.dll`, `libifcoremd.dll`, `libmmd.dll`, `svml_dispmd.dll`, `msvcp140.dll`, `vcruntime140.dll`, and `vcruntime140_1.dll`. Intel DLL bytes match the package-member SHA256 records in the pinned intel-fortran-rt/intel-cmplr-lib-rt packages and are named by the accompanying compiler `fredist.txt`. Preserve the Intel EULA and applicable third-party notices. MS-MPI retains the exact Gate 0 provenance/EULA/TPN. VC DLLs came from the installed VS Build Tools release x64 Microsoft.VC143.CRT redist directory; they were not copied from System32.

The applicable Microsoft review sources are [Visual Studio 2022 redistribution](https://learn.microsoft.com/en-us/visualstudio/releases/2022/redistribution) and [Build Tools 2022 terms](https://visualstudio.microsoft.com/license-terms/vs2022-ga-diagnosticbuildtools/). The redistribution page makes use conditional on license terms; a file's presence in a redist directory is not evidence that every distribution obligation has been fulfilled. License applicability, downstream terms/notices and final package review remain pending. No debug CRT, compiler, SDK, OS DLL, MPI service or launcher is selected for this closure.

Restricted-PATH execution with Unicode/space paths observed the seven vendor DLLs loading from the application directory. This is useful developer-host evidence, not a substitute for clean standard-user/offline validation or proof covering every possible dynamic-loading code path.
