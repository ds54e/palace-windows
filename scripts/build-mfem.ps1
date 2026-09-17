[CmdletBinding()]
param()
. "$PSScriptRoot/gate2-common.ps1"
$intel = "$root/.work/deps/intel/Library/lib"
$runtime = "$intel/libifcoremd.lib;$intel/libifportmd.lib;$intel/libmmd.lib;$intel/svml_dispmd.lib"
$hypreLibraries="$prefix/lib/HYPRE.lib;$sdk/msmpi64.lib;$blas"
$mumpsLibraries="$prefix/lib/dmumps.lib;$prefix/lib/mumps_common.lib;$prefix/lib/pord.lib;$prefix/lib/metis.lib;$blas;$sdk/msmpi64.lib;$sdk/msmpifec64.lib;$scalapack;$runtime"
$build = "$root/.work/build/no-parmetis-mfem"
& cmake.exe -S "$root/.work/sources/mfem" -B $build @common `
    '-DCMAKE_CXX_FLAGS=/EHsc /utf-8 /DPW_MUMPS_NO_PARMETIS' `
    "-DHYPRE_LIBRARIES=$hypreLibraries" "-DMUMPS_LIBRARIES=$mumpsLibraries" `
    "-DHYPRE_INCLUDE_DIRS=$prefix/include;$sdk" "-DMUMPS_INCLUDE_DIRS=$prefix/include;$sdk" `
    -DMFEM_WINDOWS_ASSERTIONS=ON -DMFEM_USE_MPI=ON -DMFEM_USE_METIS=ON -DMFEM_USE_METIS_5=ON -DMFEM_USE_MUMPS=ON `
    -DMFEM_USE_LAPACK=ON -DMFEM_USE_OPENMP=OFF -DMFEM_USE_CEED=OFF -DMFEM_USE_GSLIB=OFF `
    -DMFEM_USE_SUPERLU=OFF -DMFEM_USE_STRUMPACK=OFF -DMFEM_USE_SUNDIALS=OFF -DMFEM_USE_ZLIB=OFF `
    -DMFEM_USE_EXCEPTIONS=ON -DMFEM_ENABLE_EXAMPLES=OFF -DMFEM_ENABLE_MINIAPPS=OFF `
    "-DHYPRE_DIR=$prefix" '-DHYPRE_REQUIRED_PACKAGES=MPI;BLAS;LAPACK' `
    "-DMETIS_DIR=$prefix" "-DMUMPS_DIR=$prefix" `
    '-DMUMPS_REQUIRED_PACKAGES=METIS;LAPACK;BLAS;MPI;MPI_Fortran;Threads' `
    "-DMUMPS_REQUIRED_LIBRARIES=$scalapack;$runtime" `
    "-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas" -DBLA_SIZEOF_INTEGER=4
Complete-Build $build
