#include "Variables.hpp"
#include <vector>
#include <string>
#include <format>

std::ostream& operator<<(std::ostream& os, const Var& v){
  std::string vname = std::format("({},{})", v.name, v.getVariableType());
  os << vname;
  return os;
}

std::vector<Var> buildVarVector(size_t N) {
  std::vector<Var> vars;
  for (size_t t = 0; t < N; t++) {
    vars.push_back(Var());
  }
  return vars;
}

std::vector<Var> buildVarVector(const std::vector<std::string> &names) {
  std::vector<Var> vars;
  int p = names.size();
  for (size_t t = 0; t < p; t++) {
    vars.push_back(Var(names[t]));
  }
  return vars;
}