# Codex kickoff

Use this as the initial task after cloning the repository onto the Windows filesystem and launching Codex from WSL with **Astra/low**.

---

Implement Palace Windows through release-ready V1.0. Read AGENTS.md, docs/STATE.json, docs/V1_PLAN.md, and docs/CODEX_OPERATIONS.md. Preserve administrator-free native Windows deployment as a hard requirement. Do not spend effort on Linux feature parity, GPU, or an elaborate model router.

Start by inspecting the real local environment. Record Codex CLI version and effective model/effort. Check the WSL-to-Windows bridge with `bash tools/windows.sh doctor`. Do not install or elevate automatically. Resolve workspace paths dynamically; the expected E: drive path is an example, not permission to write to unrelated locations.

Upstream Palace v0.18.0 is pinned by commit in deps/upstream.json. Verify the source against that pin and inspect its build requirements and the WelSim Windows prior art. Do not chase new upstream releases during this V1 effort. The dependency lock is intentionally incomplete until the stack is tested.

Before building Palace, execute the Gate 0 MPI deployment investigation. The probe and runner are supplied, but Windows execution and clean-host evidence are not yet present. Do not claim a pass merely because the code exists. Check provenance of runtime files before proposing to ship them.

When Gate 0 succeeds, continue through ABI tests, core dependencies, native Palace, C/L/S/eigen validation, package assembly, clean-host validation, and reproducible release-ready artifacts. Implement the missing build/packaging pieces as real scripts; no success-returning placeholders. Use one writer and one heavy build. The optional Luna child template requires local support and actual-model verification before activation.

Use Astra/low as the normal parent. Do not raise Astra effort autonomously. If Astra becomes quota-constrained or clearly poor value for a sustained phase, checkpoint the repository and recommend the owner-authorized Sol/medium fallback described in docs/CODEX_OPERATIONS.md; do not self-restart or silently switch models.

Commit coherent checkpoints. Update STATE.json, DEVLOG.md, and DECISIONS.md with evidence. Continue ordinary in-scope engineering without repeated confirmation. For a genuine host privilege, licensing, quota, or unavailable-tool blocker, report the exact next owner action and continue independent work where possible.

Stop only at READY_FOR_RELEASE_REVIEW or a genuine external blocker, not after a documentation-only phase. Keep the repository private. Do not create the public release, change visibility, purchase credits, change global Codex settings, or weaken endpoint security. Prepare the final owner report with artifact locations/hashes, tested environment, supported features, test results, measured size/memory, signature status, and remaining limitations.
