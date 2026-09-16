# MSVC test portability

Base: opencollab/arpack-ng commit `804fa3149a0f773064198a8e883bd021832157ca`, as pinned by Palace v0.18.0. Apply after the three Palace-provided ARPACK patches recorded in `deps/gate1-lock.json`. The upstream files remain under their original ARPACK-NG licenses (see the pinned source's COPYING); this patch does not relicense them.

`msvc-test-constant-bounds.patch` preserves upstream tests and tolerances. Four C tests use arrays whose dimensions are fixed test constants but represented as C variables; MSVC does not implement C variable-length arrays. Convert those bounds to enum constants. For MSVC's struct-based C complex representation, use the UCRT `_Cmulcc` operation in the two complex matrix-vector helpers. The non-MSVC expression remains unchanged. Parallel test multipliers are small integer values exactly representable in both float and double.

This patch changes test portability only, not solver algorithms. Test execution results are recorded separately; compiling a test does not establish a pass.
