#include <mfem.hpp>
#include <cmath>
#include <iostream>
#include <memory>
#include <string>
#ifndef MFEM_USE_MPI
#error MPI must be enabled
#endif
#ifndef MFEM_USE_METIS
#error METIS must be enabled
#endif
#ifndef MFEM_USE_MUMPS
#error MUMPS must be enabled
#endif
static_assert(sizeof(HYPRE_Int)==4 && sizeof(HYPRE_BigInt)==4);
int main(int argc,char** argv)
{
    mfem::Mpi::Init(argc,argv);
    mfem::Hypre::Init();
    if (mfem::Mpi::WorldSize()!=1) return 1;
    bool pass=true;
    {
        auto mesh=mfem::Mesh::MakeCartesian2D(3,3,mfem::Element::QUADRILATERAL,true,1.0,1.0);
        // Explicitly exercise serial METIS partitioning, then one-rank ParMesh.
        std::unique_ptr<int[]> partition(mesh.GeneratePartitioning(2,1));
        int counts[2]={};
        for(int i=0;i<mesh.GetNE();++i) {
            if(partition[i]<0 || partition[i]>1) return 2;
            ++counts[partition[i]];
        }
        if(!counts[0] || !counts[1]) return 3;
        mfem::ParMesh parallel(MPI_COMM_WORLD,mesh);
        mfem::H1_FECollection fec(1,2);
        mfem::ParFiniteElementSpace fes(&parallel,&fec);
        mfem::ParBilinearForm form(&fes);
        form.AddDomainIntegrator(new mfem::MassIntegrator);
        form.Assemble(); form.Finalize();
        std::unique_ptr<mfem::HypreParMatrix> matrix(form.ParallelAssemble());
        mfem::Vector exact(fes.GetTrueVSize()),rhs(exact.Size()),solution(exact.Size()),residual(exact.Size());
        exact=1.0; matrix->Mult(exact,rhs);
        auto check=[&](const char* label) {
            matrix->Mult(solution,residual); residual-=rhs;
            const double rn=residual.Norml2();
            solution-=exact;
            const double en=solution.Normlinf();
            std::cout<<label<<" residual="<<rn<<" error="<<en<<'\n';
            // Fixed before execution; one rank gives global norms here.
            pass &= std::isfinite(rn) && rn <= 1e-10+1e-10*rhs.Norml2();
            pass &= std::isfinite(en) && en <= 1e-10+1e-10*exact.Normlinf();
        };
        for(auto order:{mfem::MUMPSSolver::PORD,mfem::MUMPSSolver::METIS}) {
            mfem::MUMPSSolver solver(MPI_COMM_WORLD);
            solver.SetPrintLevel(0);
            solver.SetReorderingStrategy(order);
            solver.SetOperator(*matrix);
            solution=0.0; solver.Mult(rhs,solution);
            check(order==mfem::MUMPSSolver::PORD?"MUMPS/PORD":"MUMPS/METIS");
        }
        mfem::HypreDiagScale preconditioner(*matrix);
        mfem::HyprePCG pcg(*matrix);
        pcg.SetTol(1e-12); pcg.SetMaxIter(100); pcg.SetPrintLevel(0);
        pcg.SetPreconditioner(preconditioner);
        solution=0.0; pcg.Mult(rhs,solution); check("Hypre/PCG");
        bool rejected=false;
        try {
            mfem::MUMPSSolver solver(MPI_COMM_WORLD);
            solver.SetReorderingStrategy(mfem::MUMPSSolver::PARMETIS);
        } catch(const mfem::ErrorException& e) {
            rejected=std::string(e.what()).find("ParMETIS ordering is unsupported")!=std::string::npos;
        }
        pass &= rejected;
        mfem::ParGridFunction field(&fes); field=1.0;
        mfem::ParaViewDataCollection output("mfem-connection",&parallel);
        output.SetPrefixPath("output"); output.SetDataFormat(mfem::VTKFormat::ASCII);
        output.RegisterField("constant",&field); output.Save();
        std::cout<<"ParMETIS rejection="<<rejected<<" true_dofs="<<fes.GlobalTrueVSize()<<'\n';
    }
    std::cout<<"MFEM MPI singleton "<<(pass?"PASS":"FAIL")<<'\n';
    return pass?0:1;
}
