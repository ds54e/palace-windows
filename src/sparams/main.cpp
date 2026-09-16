// SPDX-License-Identifier: Apache-2.0
// Touchstone 1.x: GHz, S, real/imaginary; two-port order 11,21,12,22.
#include <cmath>
#include <complex>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <locale>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
namespace fs = std::filesystem;
std::string trim(std::string s) {
    const auto a=s.find_first_not_of(" \t\r\n");
    return a==s.npos ? "" : s.substr(a,s.find_last_not_of(" \t\r\n")-a+1);
}
std::vector<std::string> split(const std::string &s) {
    std::vector<std::string> v; std::stringstream in(s); std::string item;
    while(std::getline(in,item,',')) v.push_back(trim(item));
    if(!s.empty() && s.back()==',') v.emplace_back();
    return v;
}
double number(const std::string &s) {
    std::istringstream in(s); in.imbue(std::locale::classic()); double x;
    if(!(in>>x) || !(in>>std::ws).eof() || !std::isfinite(x))
        throw std::runtime_error("Invalid or non-finite numeric value: "+s);
    return x;
}
int convert(const std::vector<fs::path> &args) {
    try {
        if(args.size()!=5 && args.size()!=6) throw std::runtime_error(
          "Usage: palace-sparams input.csv output.s1p|output.s2p impedance-ohms port1 [port2]\n"
          "Impedance must equal the common real reference impedance used by Palace; no renormalization is performed.");
        const double z=number(args[3].string());
        if(z<=0) throw std::runtime_error("Reference impedance must be positive.");
        std::vector<int> ports;
        for(size_t i=4;i<args.size();++i) {
            double p=number(args[i].string());
            if(p<1 || p>2147483647 || p!=std::floor(p)) throw std::runtime_error("Invalid port index.");
            ports.push_back(static_cast<int>(p));
        }
        if(ports.size()==2 && ports[0]==ports[1]) throw std::runtime_error("Port indices must be distinct.");
        if(args[2].extension()!=(ports.size()==1 ? ".s1p" : ".s2p")) throw std::runtime_error("Output extension must match port count.");
        if(fs::exists(args[2])) throw std::runtime_error("Output already exists; choose a new filename.");
        std::ifstream in(args[1]); if(!in) throw std::runtime_error("Cannot open input CSV.");
        std::string line; if(!std::getline(in,line)) throw std::runtime_error("Empty CSV.");
        auto labels=split(line); std::map<std::string,size_t> index;
        for(size_t i=0;i<labels.size();++i) if(!index.emplace(labels[i],i).second) throw std::runtime_error("Duplicate column.");
        if(!index.count("f (GHz)")) throw std::runtime_error("Expected f (GHz) column.");
        std::vector<std::pair<size_t,size_t>> columns;
        for(int j:ports) for(int i:ports) {
            auto s="S["+std::to_string(i)+"]["+std::to_string(j)+"]";
            auto mag=index.find("|"+s+"| (dB)"), phase=index.find("arg("+s+") (deg.)");
            if(mag==index.end() || phase==index.end()) throw std::runtime_error("Missing complete complex matrix entry: "+s);
            columns.emplace_back(mag->second,phase->second);
        }
        std::ostringstream out; out.imbue(std::locale::classic()); out<<std::setprecision(17);
        out<<"! Palace port order:"; for(int p:ports) out<<' '<<p;
        out<<"\n! Reference impedance asserted by caller; no renormalization.\n# GHz S RI R "<<z<<'\n';
        double previous=-1; size_t count=0;
        while(std::getline(in,line)) {
            if(trim(line).empty()) continue;
            auto fields=split(line); if(fields.size()!=labels.size()) throw std::runtime_error("CSV row width mismatch.");
            std::vector<double> row; for(auto &s:fields) row.push_back(number(s));
            double f=row[index.at("f (GHz)")];
            if(f<0 || f<=previous) throw std::runtime_error("Frequencies must be nonnegative and strictly increasing.");
            previous=f; out<<f;
            for(auto c:columns) {
                auto value=std::polar(std::pow(10.0,row[c.first]/20.0),row[c.second]*std::acos(-1.0)/180.0);
                if(!std::isfinite(value.real()) || !std::isfinite(value.imag())) throw std::runtime_error("Complex value overflow.");
                out<<' '<<value.real()<<' '<<value.imag();
            }
            out<<'\n'; ++count;
        }
        if(in.bad() || !count) throw std::runtime_error("Input read failed or no frequency rows.");
        std::ofstream file(args[2],std::ios::binary); file<<out.str(); file.close();
        if(!file) throw std::runtime_error("Output write failed.");
        std::cout<<"Exported "<<count<<" frequencies.\n"; return 0;
    } catch(const std::exception &e) { std::cerr<<e.what()<<'\n'; return 1; }
}
#ifdef _WIN32
int wmain(int argc,wchar_t **argv) {
#else
int main(int argc,char **argv) {
#endif
    std::vector<fs::path> args; for(int i=0;i<argc;++i) args.emplace_back(argv[i]);
    return convert(args);
}
