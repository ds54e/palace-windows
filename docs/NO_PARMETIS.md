# Windows V1 without ParMETIS

Owner-selected on 2026-09-17. Base Palace v0.18.0 commit b92aef83ecfe6d360c4b3d83e2122986297f6778 is unchanged; repository overlay patches record all source changes. MPI remains enabled. This choice does not waive Gate 0 clean-host/offline or redistribution review.

## Dependency trace

| Pinned source location | Assumption | Windows overlay treatment |
| --- | --- | --- |
| Palace cmake/ExternalMETIS.cmake | Builds ParMETIS whenever MUMPS/SuperLU/STRUMPACK is selected | Suppress ParMETIS ExternalProject only for the explicit Windows variant |
| Palace cmake/ExternalMUMPS.cmake | Depends on parmetis target; sets parmetis=ON and library hint | Remove target dependency; parmetis=OFF; retain metis=ON and PORD |
| Palace cmake/ExternalMFEM.cmake | Passes ParMETIS libraries and lists it among MUMPS required packages | Remove those convenience requirements for this variant; retain MPI, MPI_Fortran, METIS, BLAS/LAPACK, Threads and ScaLAPACK |
| Palace palace/CMakeLists.txt | Unconditionally finds and links ParMETIS | Conditional discovery/linking; preserve METIS |
| Palace cmake/ExternalPalace.cmake | Forwards dependency locations | Forward explicit variant flag; unused directory hints do not create dependencies |
| Palace ExternalSuperLU_DIST/ExternalSTRUMPACK | Request ParMETIS | These solvers are OFF; reject enabling them in this overlay rather than silently altering their configuration |
| Palace ExternalGitTags.cmake and Spack recipe | Pins/downloads or declares ParMETIS | Preserve historical source/provenance; Spack is not the Windows recipe |
| MFEM config/defaults.cmake | MUMPS_REQUIRED_PACKAGES defaults to MPI/MPI_Fortran/ParMETIS/METIS | Override the supported cache variable; no need to alter the finder |
| MFEM config/defaults.mk | Make-based solver link defaults include ParMETIS | Not used by native CMake recipe |
| MFEM mesh partitioning | Uses METIS, including before constructing ParMesh | Retain and test METIS; no ParMETIS code requirement |
| MFEM linalg/mumps.cpp | PARMETIS strategy sets MUMPS controls for distributed ordering | Preserve enum; under PW_MUMPS_NO_PARMETIS, reject explicit request with MFEM_VERIFY before factorization |
| MUMPS wrapper CMakeLists.txt | Optional parmetis branch adds -Dparmetis; metis branch is independent | Use supported metis=ON/parmetis=OFF options, no replacement library |
| MUMPS wrapper FindMETIS.cmake | Includes cached PARMETIS_LIBRARY if present | Separate build/install trees and explicit empty PARMETIS_LIBRARY prevent stale linkage |
| Palace linalg/mumps.cpp and utils/enum_string.cpp | Expose/forward ParMETIS enum | Preserve API and string spelling; MFEM wrapper rejects unsupported request |

Other ParMETIS references belong to disabled solvers, documentation, tests/examples for those solvers, package recipes or stored patches. They are not permission to include their object code. Merely searching an executable for the word ParMETIS is insufficient: the required diagnostic and enum names intentionally retain it.

## Runtime linkage

`cmake/WindowsIfxRuntime.cmake` resolves exact libifcoremd, libifportmd, libmmd and svml_dispmd import libraries beside the pinned ifx compiler. It compiles a Fortran allocation/I/O routine, links it using the MSVC C++ linker and explicit libraries, and fails configure if linkage fails. The same probe is also executed by the connection suite. MFEM's MUMPS closure receives these libraries plus the exact oneMKL ScaLAPACK/BLACS libraries. Non-Windows/upstream guard behavior remains unchanged.

## Validation scope

Native MUMPS PORD and METIS solves have passed the existing fixed Gate 1 tolerances, with INFOG(7) confirming orderings 4 and 5 respectively. Both residual infinity norms were 1.77636e-15. Explicit MSVC/ifx linkage and execution passed. MPI-enabled Hypre built. The overlay superbuild configured successfully without a ParMETIS target; this is not a complete Palace build.

MPI-enabled MFEM connection passed: one-rank ParMesh/assembly, Hypre PCG, MUMPS PORD/METIS, explicit ParMETIS rejection, and ParaView Save. Fixed residual/solution tolerances and binary hashes are in `evidence/G2-no-parmetis-connections-2026-09-17.json`. The initial static/export audit found no ParMETIS implementation symbols or exported dependency in ten installed libraries. Final Palace binary/link-map closure and C/L/S/eigen numerical acceptance remain separate requirements.
