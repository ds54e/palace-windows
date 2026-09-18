# Redistribution matrix — METIS-remediated candidate

**Status: COMPONENT_REMEDIATION_REVIEW_COMPLETE.**

| Component | Version/commit | Linkage | License | Status |
|---|---|---|---|---|
| palace | b92aef83ecfe6d360c4b3d83e2122986297f6778 | static into palace.exe | Apache-2.0 | COMPONENT_REVIEW_COMPLETE |
| mfem | d9d6526cc1749980a2ba1da16e2c1ca1e07d82ec | static into palace.exe | BSD-3-Clause | COMPONENT_REVIEW_COMPLETE |
| hypre | fca98afcd78a26b784dc24b0c3edb0e6140598af | static into palace.exe | Apache-2.0 AND MIT | COMPONENT_REVIEW_COMPLETE |
| mumps | MUMPS 5.7.3 archive 84a47f7c4231b9efdf4d4f631a2cae2bdd9adeaabc088261d15af040143ed112; wrapper 1cfd19699702f9a64ff5d45827d6025ff5c3873a | static into palace.exe | CECILL-C with exceptions in LICENSE | COMPONENT_REVIEW_COMPLETE |
| arpack-ng | 804fa3149a0f773064198a8e883bd021832157ca | static into palace.exe | BSD-3-Clause | COMPONENT_REVIEW_COMPLETE |
| libCEED | 39f259f89332e936122f7e02d6088a1dae3fb628 | static into palace.exe | BSD-2-Clause | COMPONENT_REVIEW_COMPLETE |
| json-schema-validator | c780404a84dd9ba978ba26bc58d17cb43fa7bc80 | static into palace.exe | MIT | COMPONENT_REVIEW_COMPLETE |
| fmt | 407c905e45ad75fc29bf0f9bb7c5c2fd3475976f | static into palace.exe | MIT | COMPONENT_REVIEW_COMPLETE |
| scn | e937be1a52588621b406d58ce8614f96bb5de747 | static into palace.exe | Apache-2.0 | COMPONENT_REVIEW_COMPLETE |
| PORD | MUMPS 5.7.3 PORD/README SPACE provenance | static into palace.exe | Public domain per bundled PORD/README | COMPONENT_REVIEW_COMPLETE |
| eigen | 549bf8c75b6aae071cde2f28aa48f16ee3ae60b0 | header implementation incorporated into palace.exe | MPL-2.0 with per-file permissive exceptions | COMPONENT_REVIEW_COMPLETE |
| json | 55f93686c01528224f448c19128836e7df245f72 | header implementation incorporated into palace.exe | MIT | COMPONENT_REVIEW_COMPLETE |
| fast_float | 00c8c7b0d5c722d2212568d915a39ea73b08b973 | header implementation incorporated into palace.exe | MIT OR Apache-2.0 OR BSL-1.0 | COMPONENT_REVIEW_COMPLETE |
| METIS / GKlib | PETSc METIS 08c3082720ff9114b8e3cbaa4484a26739cd7d2d with attributed sorting/exclusion prior art from NetworkX-METIS 26a51ddad5932d843655e5b7ba1225bcfe3b8882 | shared; no METIS implementation objects in palace.exe | Apache-2.0 and applicable per-file permissive notices for selected runtime code; LGPL-2.1-or-later applies to excluded source-only GKlib files retained in corresponding source | COMPONENT_REVIEW_COMPLETE |
| libifcoremd.dll | intel-fortran-rt-2025.3.0-intel_640.conda | shared DLL; import records in palace.exe, not static implementation | Intel Developer Tools EULA August 2024 | COMPONENT_REVIEW_COMPLETE |
| libircmd.dll | intel-cmplr-lib-rt-2025.3.0-intel_640.conda | shared DLL; import records in palace.exe, not static implementation | Intel Developer Tools EULA August 2024 | COMPONENT_REVIEW_COMPLETE |
| libmmd.dll | intel-cmplr-lib-rt-2025.3.0-intel_640.conda | shared DLL; import records in palace.exe, not static implementation | Intel Developer Tools EULA August 2024 | COMPONENT_REVIEW_COMPLETE |
| Microsoft MPI runtime | 10.1.12498.18 | shared DLL | Microsoft MPI Redistributable EULA | COMPONENT_REVIEW_COMPLETE |
| Microsoft VC runtime msvcp140.dll | VC143 x64; file 14.44.35211.0; product 14.44.35211.0 | shared DLL | Visual Studio Community 2022 distributable-code terms / runtime-use terms | COMPONENT_REVIEW_COMPLETE |
| svml_dispmd.dll | intel-cmplr-lib-rt-2025.3.0-intel_640.conda | shared DLL; import records in palace.exe, not static implementation | Intel Developer Tools EULA August 2024 | COMPONENT_REVIEW_COMPLETE |
| Microsoft VC runtime vcruntime140.dll | VC143 x64; file 14.44.35211.0; product 14.44.35211.0 | shared DLL | Visual Studio Community 2022 distributable-code terms / runtime-use terms | COMPONENT_REVIEW_COMPLETE |
| Microsoft VC runtime vcruntime140_1.dll | VC143 x64; file 14.44.35211.0; product 14.44.35211.0 | shared DLL | Visual Studio Community 2022 distributable-code terms / runtime-use terms | COMPONENT_REVIEW_COMPLETE |
| oneMKL LP64 sequential | intelmkl.static.win-x64.2025.3.0.453.nupkg | static into palace.exe | Intel Simplified Software License October 2022 plus third-party terms | COMPONENT_REVIEW_COMPLETE |
| oneMKL cluster | intelmkl.static.cluster.win-x64.2025.3.0.453.nupkg | static into palace.exe | Intel Simplified Software License October 2022 plus third-party terms | COMPONENT_REVIEW_COMPLETE |
| Microsoft MPI SDK Fortran binding | 10.1 SDK locked official package | static binding into palace.exe | Microsoft MPI SDK EULA | COMPONENT_REVIEW_COMPLETE |
| Microsoft VC startup/support | MSVC 14.44.35207; compiler 19.44.35219 | static portions into palace.exe and palace-sparams.exe | Visual Studio Community 2022 / applicable C++ component licenses | COMPONENT_REVIEW_COMPLETE |
| Microsoft STL header implementation | MSVC 14.44.35207; installed vector header SPDX; upstream vs-2022-17.14 license | header code in both executables | Apache-2.0 WITH LLVM-exception | COMPONENT_REVIEW_COMPLETE |
| Windows overlay / palace-sparams | Compiled Palace overlay: 83b6474; utility source src/sparams/main.cpp SHA256 34302597a55ab4a34f25c994e92badb5098068dcf86d369149898216f59a6bed; package recipe commit bound by build-manifest.json | executable and source changes | Apache-2.0 | COMPONENT_REVIEW_COMPLETE |

The JSON matrix is controlling and contains exact hashes, rights, notices, source obligations and evidence.
