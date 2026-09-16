# Exact-payload redistribution review

Status: in progress; no redistribution approval or public release. This record separates a license grant from fulfillment of its conditions. Binary identities must be tied to the final staging manifest. Linux reference compiler/runtime packages are not part of the Windows payload.

## Proprietary runtime components

| Component | Grant/evidence | Required package actions | Outstanding facts |
| --- | --- | --- | --- |
| MS-MPI 10.1.12498.18, exact msmpi.dll from the locked Microsoft installer | Accompanying Microsoft MPI Redistributable EULA §2(a) grants binary distribution with an application; §1 limits use to Windows | Preserve unmodified bytes, original EULA and TPN; Palace supplies substantial primary functionality; downstream terms must protect Microsoft at least as much; no endorsement or relicensing of Microsoft code | Publisher must fulfill §2(b), including indemnity and downstream agreement; package terms under preparation |
| libifcoremd.dll, libmmd.dll, svml_dispmd.dll, exact Intel 2025.3 package members | Accompanying Developer Tools EULA August 2024 §2.1(D), and exact DLL names in compiler fredist.txt | Product-only binary distribution; preserve EULA/third-party notices; convey reverse-engineering restriction for proprietary runtime and §7 liability terms; avoid endorsement; retain statutory/open-source exceptions | Final downstream terms and attribution audit pending |
| Embedded Intel compiler support code (including libircmt objects shown in Palace link map) | Accompanying compiler EULA; Intel deployment documentation explicitly describes deploying applications linked with compiler static libraries | No standalone compiler/static-library redistribution; preserve compiler license and third-party notices; same proprietary-runtime conditions | Confirm the exact scope of contemporary grant/documentation; do not confuse a default link directive with actual object inclusion |
| msvcp140.dll, vcruntime140.dll, vcruntime140_1.dll and embedded VC startup/support | Exact release x64 VC redist directory; Microsoft's VS 2022 redistribution list and applicable VS product license | Preserve bytes and applicable terms; no debug runtime/SDK/compiler; satisfy distributable-code conditions | Owner VS license/eligibility confirmation requested; Build Tools installation alone and the VC Runtime use-only license do not establish redistribution rights |
| Embedded oneMKL 2025.3 LP64 sequential, ScaLAPACK and MS-MPI BLACS | Intel Simplified Software License October 2022 accompanying both locked NuGet packages | Preserve copyright/license and all applicable TPN files; no endorsement; no proprietary-code reverse engineering/modification; preserve any third-party exceptions | Exact stage notice coverage pending |

Primary Microsoft references: [VS 2022 redistribution](https://learn.microsoft.com/en-us/visualstudio/releases/2022/redistribution), [Build Tools terms](https://visualstudio.microsoft.com/license-terms/vs2022-ga-diagnosticbuildtools/), [VC Runtime use terms](https://visualstudio.microsoft.com/license-terms/vs2022-cruntime/). Downloaded official DOCX identities are retained in `.work/licensing/*-source.json`. The VC Runtime use terms expressly restrict standalone/combined redistribution; they must not be substituted for an applicable developer redistribution grant.

Intel source: [compiler application deployment guidance](https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2023-2/redistribute-libraries-when-deploying-apps.html), plus the exact accompanying EULA/fredist/TPN (the package's license, not an unrelated latest web license, is the primary binary evidence). The fredist file's introductory date references April 2023 while the accompanying EULA is August 2024; retain both verbatim and record that discrepancy.

## Code compiled into palace.exe

| Component | License/evidence in pinned source | Package fulfillment |
| --- | --- | --- |
| Palace and Windows overlay | Apache-2.0, upstream LICENSE and repository LICENSE | License, applicable upstream notices, modification description, exact source/patch identities |
| MFEM | BSD-3-Clause LICENSE and NOTICE | Both verbatim; Windows changes identified |
| Hypre | LICENSE-APACHE / LICENSE-MIT and NOTICE | Include all accompanying terms/notices; retain upstream source identity |
| METIS / GKlib | Apache-2.0 top-level license plus LGPL-2.1-or-later `GKlib/gk_mksort.h` and per-file notices | Full corresponding source and LGPL text/notices included; static-link/relinking and downstream-term review remains open; no ParMETIS files |
| MUMPS 5.7.3 | CeCILL-C; LICENSE, doc/CeCILL-C_V1-en.txt and -fr.txt; BSD exceptions named in LICENSE | Include full corresponding MUMPS source archive, license and warranty/liability notice; accessible interface attribution required by §6.4; build-wrapper changes identified separately |
| PORD | MUMPS PORD/README records SPACE public-domain provenance | Preserve README and bundled source notices in MUMPS source archive |
| ARPACK/PARPACK | BSD COPYING, including named copyright holders | COPYing verbatim, source/patch identities |
| libCEED | BSD-2-Clause LICENSE and additional DOE NOTICE | Both verbatim; allocation/registration port modifications identified |
| Eigen 5.0.0 | MPL-2.0 LICENSE/COPYING.MPL2; COPYING.README and accompanying permissive exception texts | Full corresponding source snapshot and all COPYING files, source availability notice; no implication that MPL licenses proprietary runtimes |
| nlohmann JSON | MIT LICENSE.MIT | Verbatim notice |
| JSON schema validator | MIT LICENSE | Verbatim notice |
| fmt | MIT LICENSE | Verbatim notice |
| scn | Apache-2.0 LICENSE | License and complete corresponding source snapshot |
| fast_float v6.1.6, commit 00c8c7b0d5c722d2212568d915a39ea73b08b973 | MIT / Apache-2.0 / Boost-1.0 alternatives, accompanying LICENSE files | Preserve all accompanying license files and source; actual header dependency of scn |

CeCILL-C §§5.3.1–5.3.3 require effective covered-source access throughout distribution; §6.4 requires attribution accessible from the derivative software interface. MPL-2.0 §3.2 likewise requires source availability for covered code. Shipping corresponding source alongside the executable avoids reliance solely on a live upstream URL. The derivative application and third-party components keep their respective licenses; proprietary runtime restrictions must not purport to remove open-source rights in unrelated components.

ParMETIS remains excluded, with its restrictive upstream license evidence preserved in `docs/REDISTRIBUTION.md`. Its preserved enum/unsupported diagnostic is not third-party ParMETIS implementation code.

The embedded libircmt support implementation is not named in the accompanying fredist list, although libircmd.dll/libircmd.lib/libircdisp.lib are named. General Intel static-deployment guidance is evidence of intended use, but is not treated here as an exact-file redistribution grant overriding the EULA definition. This scope remains unresolved; no compiler/runtime change has been made to hide the issue. A vendor/license clarification or separately validated licensed linkage route is required before closing the package review.

## GKlib license finding in the actual binary

The pinned `GKlib/gk_mksort.h` contains LGPL-2.1-or-later sorting macros, substantially longer than the small-header exception. `libmetis/gklib.c` instantiates them; the final Palace map contains `libmetis__ikvsorti`, `libmetis__ikvsortd` and `libmetis__rkvsortd` from `metis:gklib.c.obj`. Thus this is linked implementation evidence, not merely an unused source-file notice. The unused getopt/regex source also carries LGPL notices, but no corresponding implementation was found in the Palace map.

The complete METIS/GKlib source and GNU LGPL-2.1 text are included. Before distribution, close LGPL §6's complete relinking-material and modification/debugging terms requirements for the static combination, including interaction with proprietary numerical/compiler support. Source inclusion alone is not being declared sufficient here. The package currently lacks an independently exercised complete relinking kit; no LGPL exception or top-level Apache-only interpretation is assumed. A suitable replaceable shared-library route is another possible engineering response, but has not been built or validated and is not represented as the current candidate.

Primary license: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt (download identity retained in `.work/licensing/lgpl-source.json`). This finding blocks redistribution approval, not the already completed numerical result. Preserve the validated dependency stack until a defensible compliance route is selected; do not quietly change numerical inputs, ordering or acceptance limits.
