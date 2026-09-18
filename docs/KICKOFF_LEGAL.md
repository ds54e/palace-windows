# Codex handoff: resolve licensing before clean-host work

Read AGENTS.md, docs/LEGAL_RESOLUTION.md, the current exact-payload review and docs/STATE.json.

The owner has deferred the independent clean-Windows test. Do not continue VM creation, ISO acquisition, Windows edition changes or hypervisor work. Do not mark clean-host testing passed. Preserve review2 and its ZIP hash unchanged.

Use this review branch, or a child review branch based on it, after checking local uncommitted changes. Do not merge main or publish anything. Keep Sol/medium and the existing one-writer/one-heavy-build policy.

The next task is an actual bounded source remediation, not another open-ended abstract LGPL/Intel interpretation. Investigate and implement the NetworkX-METIS standard-library sorting/exclusion approach described in docs/LEGAL_RESOLUTION.md against the CURRENT pinned METIS source. The reference commit and file identities are in deps/metis-remediation-reference.json.

This narrowly scoped remedy supersedes the earlier instruction to preserve GKlib sorting unchanged solely while awaiting a legal opinion. It does not authorize changes to Intel, BLAS, sparse/eigen solvers, compiler ABI, numerical tolerances, global permissions, billing, repository visibility or the frozen candidate.

First produce the smallest source diff with file-level provenance. Preserve current METIS APIs/Fortran exports and shared-library deployment. Exclude all selected LGPL sorting/getopt/regex implementation or retained data; do not hide license notices or stub required behavior. Then build in a new prefix, run focused sorting/order tests, all four solver cases and the fixed numerical comparisons, and inspect the final source-to-object-to-DLL chain. See the detailed acceptance rules in docs/LEGAL_RESOLUTION.md.

Continue ordinary local implementation and tests without stopping for another planning-only checkpoint. Update progress/evidence on the review branch and keep old evidence immutable. If no appropriate Windows host is available in this session, report that precisely; do not claim native validation from Linux/static checks.

Only after the new artifact actually removes the identified licensed implementation and passes the required evidence checks may the narrow issue be recorded as RESOLVED_BY_COMPONENT_REPLACEMENT for its exact hashes. Do not certify compatibility of the old binary. Leave clean-host testing deferred and final publication owner-controlled.

Return the tested commit, resulting commit, exact new artifact hashes (or explicitly no artifact), comparison results, exclusion evidence, changed license matrix entries and any concrete unresolved item. Do not rebuild or replace the frozen ZIP in place.
