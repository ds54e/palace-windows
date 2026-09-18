# Pinned METIS permissive sorting overlay

Target: PETSc `pkg-metis` commit
`08c3082720ff9114b8e3cbaa4484a26739cd7d2d`.

`permissive-sort-exclusion.patch` backports only the sorting and source-
exclusion approach published by NetworkX-METIS commit
`26a51ddad5932d843655e5b7ba1225bcfe3b8882`. The two added C++ sorting files
are byte-for-byte copies of that commit before patch framing. NetworkX-METIS
identifies the derivative, NetworkX Developers and the Regents of the
University of Minnesota under Apache-2.0 in its `NOTICE`, `LICENSE.txt` and
`src/LICENSE.txt`. Exact Git blob and SHA256 identities are locked in
`deps/metis-remediation-reference.json`.

The patch:

- keeps the current pinned METIS algorithms, C ABI, 32-bit `idx_t`/`real_t`,
  shared-library build and Windows Fortran exports;
- moves all ten libmetis sorting entry points from the LGPL-derived
  `GK_MKQSORT` macro to the attributed `std::sort` implementation;
- supplies the corresponding attributed GKlib `std::sort` wrappers;
- removes the regex-dependent unused GKlib string routine;
- removes `gk_mksort.h`, `gk_getopt.h` and `gkregex.h` from compiled include
  paths; and
- excludes `sort.c`, `getopt.c` and `gkregex.c` from the selected library
  source list.

For the C++ bridge only, `gk_arch.h` uses the standard integer headers shipped
with current MSVC rather than GKlib's pre-C++11 MSVC compatibility typedefs.
The existing C compilation path retains those compatibility headers and both
paths retain GKlib's Windows stat compatibility. This prevents duplicate
`int8_t`/`int_fast16_t` definitions and avoids unavailable POSIX time headers
without changing public types or the `idx_t`/`real_t` configuration.

The original LGPL-covered files remain in the pinned source tree for source
provenance. They are not relabeled, deleted from history or selected for the
new binary. Their notices remain applicable to the source bundle. Final
preprocessor, object, map and binary audits determine whether the runtime
exclusion succeeds; this README alone is not evidence of a passed build.
