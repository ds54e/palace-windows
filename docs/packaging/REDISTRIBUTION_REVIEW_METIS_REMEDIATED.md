# Redistribution review — METIS-remediated candidate

This review applies only to the exact hashes in
`REDISTRIBUTION_MATRIX_METIS_REMEDIATED.json` and the staged manifest. It does
not revise the frozen review2 artifact or express a legal opinion about that
historical binary.

The pinned METIS library remains a replaceable app-local DLL. Its runtime source
selection now excludes GKlib `sort.c`, `getopt.c` and `gkregex.c`, removes the
old `GK_MKQSORT` instantiations and uses the two byte-verified Apache-2.0
NetworkX-METIS C++ sorting files. The final Windows object list and map, Linux
archive/map and recursive PE import closure were audited. The exact results are
in `docs/evidence/LEGAL-metis-remediation-2026-09-18.json`.

For the new hashes, the former `LGPL_INTEL_COMBINED_WORK` question is recorded
as `RESOLVED_BY_COMPONENT_REPLACEMENT`: the identified LGPL implementation is
not incorporated into the selected runtime. Excluded LGPL files remain in the
corresponding-source archive with their license and notices. This is a factual
component-removal record, not an opinion that the old combination was compatible
or incompatible.

All other component grants, exact package evidence and downstream terms remain
as reviewed for review2. Microsoft Visual C++ redistribution relies on the
owner-confirmed eligible Visual Studio Community use. Intel, oneMKL and MS-MPI
terms remain component-specific. ParMETIS and `libircmt` remain excluded.

The package may reach release review only after its exact staged fulfillment and
hash checks pass. Gate 0 and Gate 5 remain open because the independent offline
standard-user Windows test was explicitly deferred. No release or tag is
authorized by this record.
