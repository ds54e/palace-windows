#include <mpi.h>
#include <mkl.h>
#include <cmath>
#include <complex>
#include <iostream>

extern "C" int pw_c_check(MPI_Comm);
extern "C" void pw_fortran_check(int, int*, int*, int*, int*);
static_assert(sizeof(int) == 4 && sizeof(long) == 4 && sizeof(void*) == 8);
static_assert(sizeof(MPI_Fint) == 4 && sizeof(MPI_Comm) == 4);
static_assert(sizeof(MPI_Aint) == 8 && sizeof(MPI_Count) == 8);
static_assert(sizeof(MKL_INT) == 4 && sizeof(std::complex<double>) == 16);

int main(int argc, char** argv)
{
    if (MPI_Init(&argc, &argv) != MPI_SUCCESS) return 1;
    int failure = pw_c_check(MPI_COMM_WORLD);
    int f_result = -1, f_integer = 0, f_logical = 0, f_complex = 0;
    pw_fortran_check(MPI_Comm_c2f(MPI_COMM_WORLD), &f_result, &f_integer, &f_logical, &f_complex);
    // Column-major non-symmetric product catches transposition and argument errors.
    const double a[4] = {1,3,2,4}, b[4] = {5,7,6,8};
    double c[4] = {};
    const double expected[4] = {19,43,22,50};
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, 2,2,2,1,a,2,b,2,0,c,2);
    for (int i=0; i<4; ++i)
        if (!std::isfinite(c[i]) || std::abs(c[i]-expected[i]) > 1e-12+1e-12*std::abs(expected[i])) failure = 5;
    // Explicit result pointer avoids a compiler-dependent complex return ABI.
    const std::complex<double> z[2] = {{1,2},{3,-1}}, w[2] = {{2,-1},{-1,4}};
    std::complex<double> dot;
    cblas_zdotc_sub(2,z,1,w,1,&dot);
    if (!std::isfinite(dot.real()) || !std::isfinite(dot.imag()) ||
        std::abs(dot-std::complex<double>(-7,6)) > 1e-12) failure = 6;
    const int finalized = MPI_Finalize();
    const bool pass = failure == 0 && f_result == 0 && finalized == MPI_SUCCESS;
    std::cout << "{\"status\":\"" << (pass ? "pass" : "fail")
              << "\",\"c_cpp_result\":" << failure << ",\"fortran_result\":" << f_result
              << ",\"pointer_bits\":64,\"c_int_bits\":32,\"c_long_bits\":32,\"mpi_fint_bits\":32,\"blas_int_bits\":32"
              << ",\"fortran_integer_bits\":" << f_integer << ",\"fortran_logical_bits\":" << f_logical
              << ",\"fortran_complex_bytes\":" << f_complex << "}\n";
    return pass ? 0 : 1;
}
