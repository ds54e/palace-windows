# Decisions

## D001 — Convenience first (accepted user requirement)

Native Windows x64, administrator-free end-user use, portable or per-user deployment, and no development tools required. First intended public distribution release: V1.0. Public publication remains owner-controlled.

## D002 — Conservative execution baseline

One CPU rank and one thread establish reproducibility. Threads may be enabled after validation without changing the installation contract. One process is not synonymous with one core or an inherent 4 GB memory ceiling. Distributed ranks on one host still share that host's RAM budget.

## D003 — Runtime before full build

MS-MPI application-local singleton is a candidate, not a proven solution. Test runtime and redistribution separately before investing in Palace's full dependency stack. No custom MPI implementation by default.

## D004 — Upstream pin

Palace v0.18.0, commit b92aef83ecfe6d360c4b3d83e2122986297f6778, was resolved from the official release/tag API on 2026-09-16. Dependency/toolchain pins still require local investigation. Do not promise compatibility from a version label.

## D005 — Astra-low parent with a simple cost fallback

Astra/low is the default parent for V1 because the project is long-horizon, multi-step Windows portability work where avoiding repeated failed attempts matters more than minimizing per-token price. Sol/medium is the owner-authorized cost/quota fallback parent. Luna/medium may be used only for bounded read-only extraction or factual surveys. Terra is not part of the default V1 path. Higher Astra effort requires explicit owner authorization. Model routing must remain simple and must not become a project deliverable.

## D006 — Evidence before labels

Preparation, developer-host success, clean-host success, numerical validation, and release readiness are separate states. Python bootstrap checks do not validate Windows MPI or Palace. A readiness file cannot prove its own factual claims.

## D007 — Preserve host policy and separate compilation evidence

The first real host rejected PowerShell scripts under Restricted policy. Do not add an execution-policy bypass to the bridge. Native read-only commands and a compile-only MSVC probe established useful facts independently. A compiled object and a singleton source branch do not pass Gate 0. Vendor installer redistribution statements do not establish extracted-DLL redistribution rights.

## D008 — Owner-authorized process policy and probe CRT

The owner superseded D007's prohibition on a process-only bypass: repository build/test PowerShell processes may use `-ExecutionPolicy Bypass`, after recording scopes, without persistent policy changes or circumvention of organizational policy. MachinePolicy/UserPolicy were Undefined and the authorized route succeeded. Organizational policy still takes precedence.

Use static MSVC CRT for the Gate 0 probe so its success does not rely on centrally installed VC runtime DLLs. This choice does not freeze the Palace dependency ABI. Native singleton/app-local success is established on the developer host only; clean standard-user/offline acceptance remains external.

## D009 — Continue build engineering while deployment review stays open

Owner explicitly accepts G0 native singleton evidence as a functional prerequisite for G1/G2, without marking G0 fully passed. Clean standard-user/offline testing and redistribution review remain mandatory release gates. Use the developer-host validated MSVC/ifx/MS-MPI/oneMKL LP64 path; do not replace it for dependency minimization. G1's first MUMPS solve uses parallel MUMPS with PORD; integrate Palace's METIS/ParMETIS recipe during G2. ABI and source/package identities are recorded in `docs/ABI_CONTRACT.md` and `deps/gate1-lock.json`.
