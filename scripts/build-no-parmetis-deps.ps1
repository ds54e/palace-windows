[CmdletBinding()]
param([ValidateSet('metis','mumps','hypre')][string]$Component)
. "$PSScriptRoot/gate2-common.ps1"
$build = "$root/.work/build/no-parmetis-$Component"
switch ($Component) {
  'metis' {
    & cmake.exe -S "$root/.work/sources/metis" -B $build @common `
        "-DGKLIB_PATH=$root/.work/sources/metis/GKlib" -DMETIS_USE_LONGINDEX=OFF `
        -DMETIS_USE_DOUBLEPRECISION=OFF -DSHARED=ON -DASSERT=ON -DASSERT2=ON '-DCMAKE_C_FLAGS=/D_WINDLL' `
        '-DCMAKE_SHARED_LINKER_FLAGS=/MAP /VERBOSE:LIB /EXPORT:METIS_SETDEFAULTOPTIONS /EXPORT:METIS_NODEND'
  }
  'mumps' {
    & cmake.exe -S "$root/.work/sources/mumps" -B $build @common `
        -DMUMPS_parallel=ON -DMUMPS_scalapack=ON -DMUMPS_openmp=OFF -Dintsize64=OFF `
        -DBUILD_SINGLE=OFF -DBUILD_DOUBLE=ON -DBUILD_COMPLEX=OFF -DBUILD_COMPLEX16=OFF `
        -DMUMPS_BUILD_TESTING=OFF -Dmetis=ON -Dparmetis=OFF -Dscotch=OFF `
        "-DMETIS_LIBRARY=$prefix/lib/metis.lib" "-DMETIS_INCLUDE_DIR=$prefix/include" `
        '-DPARMETIS_LIBRARY=' "-DSCALAPACK_LIBRARIES=$scalapack" `
        "-DBLAS_LIBRARIES=$blas" "-DLAPACK_LIBRARIES=$blas" -DBLA_SIZEOF_INTEGER=4 `
        "-DCMAKE_MODULE_PATH=$root/cmake" "-DPW_MUMPS_ARCHIVE=$root/.work/downloads/MUMPS_5.7.3.tar.gz"
  }
  'hypre' {
    & cmake.exe -S "$root/.work/sources/hypre/src" -B $build @common `
        -DHYPRE_ENABLE_MPI=ON -DHYPRE_ENABLE_FORTRAN=OFF -DHYPRE_ENABLE_OPENMP=OFF `
        -DHYPRE_ENABLE_MIXEDINT=OFF -DHYPRE_ENABLE_BIGINT=OFF `
        -DHYPRE_ENABLE_HYPRE_BLAS=OFF -DHYPRE_ENABLE_HYPRE_LAPACK=OFF `
        "-DTPL_BLAS_LIBRARIES=$blas" "-DTPL_LAPACK_LIBRARIES=$blas"
  }
}
Complete-Build $build
