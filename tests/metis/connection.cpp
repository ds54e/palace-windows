#include <metis.h>
#include <iostream>
static_assert(sizeof(idx_t)==4 && sizeof(real_t)==4);
int main()
{
    idx_t n=6, ncon=1, nparts=2, edgecut=-1;
    idx_t xadj[]={0,2,4,6,8,10,12};
    idx_t edges[]={1,5,0,2,1,3,2,4,3,5,0,4};
    idx_t part[6]={}, options[METIS_NOPTIONS], perm[6]={}, inverse[6]={};
    if(METIS_SetDefaultOptions(options)!=METIS_OK) return 1;
    options[METIS_OPTION_SEED]=0;
    options[METIS_OPTION_NUMBERING]=0;
    int result=METIS_PartGraphKway(&n,&ncon,xadj,edges,nullptr,nullptr,nullptr,
        &nparts,nullptr,nullptr,options,&edgecut,part);
    if(result!=METIS_OK) return 2;
    int actual_cut=0, count[2]={};
    for(int i=0;i<n;++i) {
        if(part[i]<0 || part[i]>=2) return 3;
        ++count[part[i]];
        for(idx_t j=xadj[i];j<xadj[i+1];++j)
            if(part[i]!=part[edges[j]]) ++actual_cut;
    }
    if(count[0]==0 || count[1]==0 || actual_cut!=2*edgecut) return 4;
    result=METIS_NodeND(&n,xadj,edges,nullptr,options,perm,inverse);
    if(result!=METIS_OK) return 5;
    for(int i=0;i<n;++i)
        if(perm[i]<0 || perm[i]>=n || inverse[perm[i]]!=i) return 6;
    std::cout << "{\"status\":\"pass\",\"idx_bits\":32,\"real_bits\":32,\"edge_cut\":" << edgecut << "}\n";
    return 0;
}
