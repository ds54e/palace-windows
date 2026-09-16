#include <dmumps_c.h>
#include <mpi.h>
#include <cmath>
#include <iostream>
#include <cstring>

static_assert(sizeof(MUMPS_INT) == 4);
int main(int argc, char** argv)
{
    if (MPI_Init(&argc, &argv) != MPI_SUCCESS) return 1;
    const int ordering = argc == 2 && std::strcmp(argv[1], "PORD") == 0 ? 4 :
                         argc == 2 && std::strcmp(argv[1], "METIS") == 0 ? 5 : 0;
    DMUMPS_STRUC_C id{};
    id.comm_fortran = MPI_Comm_c2f(MPI_COMM_WORLD);
    id.par = 1; id.sym = 0; id.job = -1;
    dmumps_c(&id);
    bool pass = id.infog[0] == 0;
    MUMPS_INT rows[] = {1,1,2,2,2,3,3}, cols[] = {1,2,1,2,3,2,3};
    double values[] = {4,1,2,5,1,1,3}, rhs[] = {6,15,11};
    if (pass) {
        id.icntl[0] = -1; id.icntl[1] = -1; id.icntl[2] = -1; id.icntl[3] = 0;
        if (ordering) { id.icntl[27] = 1; id.icntl[6] = ordering; }
        id.n = 3; id.nz = 7; id.irn = rows; id.jcn = cols; id.a = values; id.rhs = rhs;
        id.job = 6;
        dmumps_c(&id);
        pass = id.infog[0] == 0;
    }
    const int solve_info = id.infog[0];
    const int actual_ordering = id.infog[6];
    if (ordering && actual_ordering != ordering) pass = false;
    double residual = 0;
    const double r[] = {4*rhs[0]+rhs[1]-6,2*rhs[0]+5*rhs[1]+rhs[2]-15,rhs[1]+3*rhs[2]-11};
    for (int i=0; i<3; ++i) {
        if (!std::isfinite(rhs[i]) || std::abs(rhs[i]-(i+1)) > 1e-12+1e-12*(i+1)) pass = false;
        residual = std::fmax(residual, std::abs(r[i]));
    }
    if (!std::isfinite(residual) || residual > 1e-12+1e-12*15) pass = false;
    id.job = -2; dmumps_c(&id);
    pass = pass && id.infog[0] == 0;
    const int mpi_result = MPI_Finalize();
    pass = pass && mpi_result == MPI_SUCCESS;
    std::cout << "{\"status\":\"" << (pass ? "pass" : "fail") << "\",\"mumps_info\":"
              << solve_info << ",\"ordering\":" << actual_ordering << ",\"residual_inf\":" << residual << "}\n";
    return pass ? 0 : 1;
}
