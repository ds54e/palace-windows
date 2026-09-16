#include <parpack.hpp>
#include <algorithm>
#include <cmath>
#include <complex>
#include <iostream>
#include <vector>

static_assert(sizeof(a_int) == 4);
using Complex = std::complex<double>;
bool solve(int mode)
{
    constexpr a_int n=6, nev=2, ncv=5, lworkl=3*ncv*ncv+5*ncv;
    constexpr double tol=1e-12;
    a_int ido=0, info=1, iparam[11]={}, ipntr[14]={}, select[ncv]={};
    std::vector<Complex> resid(n,1.0), v(n*ncv), workd(3*n), workl(lworkl), d(nev+1), z(n*(nev+1)), workev(2*ncv);
    double rwork[ncv]={};
    iparam[0]=1; iparam[2]=300; iparam[6]=mode;
    const Complex sigma(1.4,0.14);
    const auto comm=MPI_Comm_c2f(MPI_COMM_WORLD);
    int calls=0;
    do {
        arpack::naupd(comm,ido,arpack::bmat::identity,n,arpack::which::largest_magnitude,nev,tol,
                      resid.data(),ncv,v.data(),n,iparam,ipntr,workd.data(),workl.data(),lworkl,rwork,info);
        if (ido==-1 || ido==1 || ido==2) {
            const int x=ipntr[0]-1, y=ipntr[1]-1;
            if(x<0 || y<0 || x+n>3*n || y+n>3*n) return false;
            for(int i=0;i<n;++i) {
                const Complex eigen(i+1,0.1*(i+1));
                workd[y+i]=ido==2 ? workd[x+i] : mode==1 ? eigen*workd[x+i] : workd[x+i]/(eigen-sigma);
            }
        } else if (ido!=99) return false;
        if(++calls>2000) return false;
    } while(ido!=99);
    if(info!=0 || iparam[4]<nev) return false;
    arpack::neupd(comm,1,arpack::howmny::ritz_vectors,select,d.data(),z.data(),n,sigma,workev.data(),
                  arpack::bmat::identity,n,arpack::which::largest_magnitude,nev,tol,resid.data(),ncv,v.data(),n,
                  iparam,ipntr,workd.data(),workl.data(),lworkl,rwork,info);
    if(info!=0) return false;
    double worst=0;
    for(int j=0;j<nev;++j) {
        double r2=0,z2=0;
        for(int i=0;i<n;++i) {
            r2+=std::norm((Complex(i+1,0.1*(i+1))-d[j])*z[j*n+i]);
            z2+=std::norm(z[j*n+i]);
        }
        if(!std::isfinite(r2) || !std::isfinite(z2) || z2<=0) return false;
        const double r=std::sqrt(r2/z2);
        if(r>1e-10+1e-10*std::abs(d[j])) return false;
        worst=std::max(worst,r);
    }
    std::sort(d.begin(),d.begin()+nev,[](Complex a,Complex b){return a.real()<b.real();});
    for(int j=0;j<nev;++j) {
        const double val=mode==1 ? 5+j : 1+j;
        if(!std::isfinite(d[j].real()) || !std::isfinite(d[j].imag()) ||
           std::abs(d[j]-Complex(val,0.1*val))>1e-10+1e-10*val) return false;
    }
    std::cout << "{\"test\":\"parpack\",\"mode\":" << mode << ",\"status\":\"pass\",\"max_residual\":" << worst << "}\n";
    return true;
}
int main(int argc,char** argv)
{
    if(MPI_Init(&argc,&argv)!=MPI_SUCCESS) return 1;
    const bool pass=solve(1) && solve(3);
    const int rc=MPI_Finalize();
    if(!pass) std::cerr << "PARPACK convergence, eigenvalue, or residual check failed\n";
    return pass && rc==MPI_SUCCESS ? 0 : 1;
}
