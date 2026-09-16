#include <cmath>
extern "C" void runtime_value(double*);
int main() { double value=0; runtime_value(&value); return std::isfinite(value) && std::abs(value-2.0)<1e-12 ? 0 : 1; }
