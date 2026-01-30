
#include "Model.hpp"
using namespace std;

std::ostream& operator<<(std::ostream& os, const Var& v) {
os << v.name;
return os;
}

std::ostream& operator<<(std::ostream& os, const Model& m) {
  os << "Model with " << m.getConstraints().size() << " constraints\n";
  return os;
}

std::vector<Var> buildVarVector(size_t N) {
std::vector<Var> vars;
for (size_t t = 0; t < N; t++) {
vars.push_back(Var());
}
return vars;
}