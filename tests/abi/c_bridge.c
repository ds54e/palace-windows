#include <mpi.h>
#include <mkl.h>
#include <stdint.h>

/* Cross a real C object boundary and exercise LP64 CBLAS from C. */
int pw_c_check(MPI_Comm comm)
{
    int rank = -1, size = -1;
    const double x[3] = {1.0, 2.0, 3.0}, y[3] = {4.0, 5.0, 6.0};
    if (sizeof(int) != 4 || sizeof(long) != 4 || sizeof(void *) != 8 ||
        sizeof(MKL_INT) != 4 || sizeof(MPI_Fint) != 4) return 1;
    if (MPI_Comm_rank(comm, &rank) != MPI_SUCCESS ||
        MPI_Comm_size(comm, &size) != MPI_SUCCESS) return 2;
    if (rank != 0 || size != 1) return 3;
    return cblas_ddot(3, x, 1, y, 1) == 32.0 ? 0 : 4;
}
