# Decisions

## D001 — Convenience first (accepted user requirement)

Native Windows x64, administrator-free end-user use, portable or per-user deployment, and no development tools required. First intended public distribution release: V1.0. Public publication remains owner-controlled.

## D002 — Conservative execution baseline

One CPU rank and one thread establish reproducibility. Threads may be enabled after validation without changing the installation contract. One process is not synonymous with one core or an inherent 4 GB memory ceiling. Distributed ranks on one host still share that host's RAM budget.

## D003 — Runtime before full build

MS-MPI application-local singleton is a candidate, not a proven solution. Test runtime and redistribution separately before investing in Palace's full dependency stack. No custom MPI implementation by default.

## D004 — Upstream pin

Palace v0.18.0, commit b92aef83ecfe6d360c4b3d83e2122986297f6778, was resolved from the official release/tag API on 2026-09-16. Dependency/toolchain pins still require local investigation. Do not promise compatibility from a version label.

## D005 — Cost policy, not router development

Terra/medium parent; optional Luna/medium read-only tasks; Sol/high for bounded hard blockers; Astra requires owner permission. Exact CLI support is checked locally. Model limits in instructions are not hard billing controls.

## D006 — Evidence before labels

Preparation, developer-host success, clean-host success, numerical validation, and release readiness are separate states. Python bootstrap checks do not validate Windows MPI or Palace. A readiness file cannot prove its own factual claims.
