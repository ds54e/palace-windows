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
