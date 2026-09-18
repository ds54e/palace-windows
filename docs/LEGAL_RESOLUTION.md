# METIS/GKlib legal-blocker remediation

Date: 2026-09-18
Status: SOURCE_RESEARCH_COMPLETE_IMPLEMENTATION_NOT_RUN
Base: ds54e/palace-windows b5f407b46662990f0d623f0c6b5c0732bb5b117d

## Current owner direction and scope

The owner explicitly deferred independent clean-Windows testing and asked to resolve the legal blocker first. Stop VM/ISO/hypervisor preparation. Record clean-host testing as deferred and unexecuted, never passed. This is a temporary work-priority change, not a claim that the existing candidate meets the original clean-host acceptance contract. Do not use the earlier informal 95% portability estimate as measured evidence.

Work on a review branch. Do not merge main, publish packages, create tags/releases, change visibility, contact vendors on the owner's behalf, or spend money. Preserve existing local changes. Sol/medium remains the default parent; there is no authorization for automatic model escalation.

Frozen review2 ZIP remains byte-identical:
`6dad1f3d892ccf20f627140760b9cae94202a12463715aa2a003e1931a5cd2e2`.
The old candidate and its legal-review record remain historical evidence. Do not relabel that artifact as cleared.

## Finding

The repository's exact-payload review identifies three live sorting functions instantiated from LGPL-covered GKlib macros, plus retained getopt/regex data in shared METIS. The existing replaceable-DLL test demonstrates replacement behavior, not a conclusion about every applicable license condition [P1]. LGPL-2.1 section 6 contains both the opening modification/debugging condition and the shared-library option; satisfying the latter alone does not remove the former [S1]. Intel's August 2024 Developer Tools terms impose restrictions on its binary redistributables and state that the package-bundled agreement controls [S2].

Do not declare the current combination lawful or unlawful by inference. Instead, first attempt a small, attributed engineering remedy that removes the identified LGPL implementation from the new runtime code. Retain Intel, MSVC/ifx, oneMKL, MUMPS, MPI, ARPACK, METIS APIs and the shared-library architecture. There is no reason yet to replace the complete compiler or numerical stack.

## Concrete prior art

NetworkX-METIS explicitly documents removing LGPL sorting, getopt and regex dependencies from its METIS 5.1.0 derivative [S3]. Its source uses C++ standard-library sorting, including the key/value routines in `src/libmetis/gklib_sort.cc`; the broader GKlib wrappers are in `src/GKlib/sort.cc` [S4]. The root and bundled-source license notices state Apache-2.0 and identify NetworkX Developers and the Regents of the University of Minnesota [S5].

Verified reference commit: `26a51ddad5932d843655e5b7ba1225bcfe3b8882`.
It is old, archived prior art, NOT a proposal to downgrade or replace the whole pinned METIS library, install NetworkX/Python, or trust a README as a complete license audit.

Keep the current PETSc METIS commit `08c3082720ff9114b8e3cbaa4484a26739cd7d2d`. Backport only the needed, reviewed sorting/exclusion changes. Source identities are recorded in `deps/metis-remediation-reference.json`; acquire exact files and record byte SHA256 before incorporation. Do not copy unrelated historical Python-wrapper changes.

## Implementation task

1. Inventory the exact METIS/GKlib translation units, headers, generated code, exports and retained data contributing to the Windows DLL. Compare the pinned upstream files with the reference. Review file-level licensing, not only top-level labels.
2. Replace required sorting implementations with the independently published Apache-licensed standard-library wrappers where applicable. Preserve attribution and modification notices. Do not translate the LGPL quicksort body into C++, rename it, or merely delete its license comment. Keep C linkage, integer widths, exported METIS/Fortran entry points and existing Windows export fixes intact. Limit C++ compilation to the necessary bridge files.
3. Remove the old macro instantiations from all selected compilation paths. Exclude unnecessary GNU getopt/regex sources, data and dependent unused routines through a documented library-only source list. Check the complete selected API closure, not merely the three functions observed in the sample map. If a needed function cannot be separated safely, report it rather than return a dummy result.
4. Build a separate candidate prefix and work directory. Reuse validated unrelated dependencies. Keep ParMETIS excluded and libircmt excluded. Do not overwrite review2, replace its expected hashes, or silently modify its sources.
5. Add focused sorting/partitioning/ordering tests. Check empty/singleton inputs, signed extrema, duplicates, ascending/descending data, integer and real key/value data, payload association and permutation/inverse consistency. Do not implement comparisons by subtraction that can overflow. Preserve the existing equal-key comparison contract; do not add tie-breaking merely to force a desired test result. Inspect floating-point assumptions and do not introduce an undefined comparator domain.
6. Run PORD and METIS connection tests and all four Palace cases with the existing 60 numerical criteria. Run matching Windows/Linux candidate comparisons using the same small source change where required. Keep the original reference and thresholds; do not overwrite them. Different equal-key order can change graph ordering and factorization fill-in, so investigate differences and record time/memory rather than promise bit-identical results or unchanged performance.
7. Audit compile dependencies/preprocessed inputs, library members, final DLL/executable maps and runtime imports. The names `ikvsorti`, `ikvsortd` and `rkvsortd` may legitimately remain for API compatibility; prove which implementation produced them. A grep for `LGPL` or missing GNU symbol names is not sufficient proof of exclusion. Include retained data and generated/inlined implementation in the review.
8. Update the changed component's provenance, sources, license notices and runtime terms for a DISTINCT candidate. Existing Intel/Microsoft grants and MUMPS/Eigen obligations remain applicable. Source-only retained LGPL material still needs its own notices and license; do not claim the entire repository or source bundle is LGPL-free merely because runtime code no longer incorporates it.

## Completion rules

Only after source/license review, native implementation, fixed-tolerance validation, final linked-code audit and exact package fulfillment should the specific blocker be recorded as `RESOLVED_BY_COMPONENT_REPLACEMENT` for the NEW hashes. This records removal of the combination that raised the question; it is not a legal opinion approving the old shared-METIS/Intel combination, nor a global legal certification.

If other linked LGPL-covered implementation remains, or the replacement provenance is unclear, leave the blocker open and identify the exact remaining file/symbol/license. Do not automatically broaden the effort into OpenBLAS/gfortran migration or permanent feature removal. Return a bounded decision request if the small remedy is insufficient.

This preparation performed repository/source/license inspection only. No patched METIS, Windows executable, numerical run, clean-host run or new ZIP was produced. Existing gate passes apply to their original source and artifact hashes, not automatically to the new candidate. Keep the original readiness checker honest; it may still reject all-gates-ready because clean-host testing is deferred.

## Sources

- [P1] Existing exact-payload review: `docs/packaging/REDISTRIBUTION_REVIEW.md` at base commit, especially the 2026-09-17 closure investigation.
- [S1] LGPL-2.1 text, section 6, FSF license reproduced by OSI: https://opensource.org/license/lgpl-2-1 . The GNU host timed out during this research; the repository already retains its downloaded source identity.
- [S2] Intel Developer Tools EULA August 2024, section 2.1.D(2), and package-control notice: https://www.intel.com/content/www/us/en/developer/articles/license/end-user-license-agreement.html . Retain the pinned packages' EULA/oneMKL license as controlling artifact evidence.
- [S3] https://github.com/networkx/networkx-metis/blob/26a51ddad5932d843655e5b7ba1225bcfe3b8882/NOTICE
- [S4] https://github.com/networkx/networkx-metis/blob/26a51ddad5932d843655e5b7ba1225bcfe3b8882/src/libmetis/gklib_sort.cc and `src/GKlib/sort.cc` at that commit.
- [S5] https://github.com/networkx/networkx-metis/blob/26a51ddad5932d843655e5b7ba1225bcfe3b8882/LICENSE.txt and `src/LICENSE.txt` at that commit.
