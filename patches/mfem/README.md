# MFEM Windows overlay

Base: d9d6526cc1749980a2ba1da16e2c1ca1e07d82ec (BSD-3-Clause), plus the six
hash-pinned CPU patches specified by Palace v0.18.0 in `deps/gate2-lock.json`.
`no-parmetis-ordering.patch` preserves the enum/API and uses MFEM_VERIFY to reject
PARMETIS when built with PW_MUMPS_NO_PARMETIS. This applies before MUMPS can choose
a fallback. It does not alter METIS/PORD/default solver behavior.

`windows-build.patch` exports UTF-8 source and exception-handling flags for MSVC
consumers and permits assertions in optimized Windows builds. The Japanese
Windows code page otherwise misparsed Unicode comments before valid members in
hyperbolic.hpp; /utf-8 fixed the observed compiler errors without source edits.
MFEM_DEBUG is set in the generated public configuration so library and consumers
agree. No numerical checks are disabled.
