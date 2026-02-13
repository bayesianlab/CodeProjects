#include "Variables.hpp"
#include <vector>
#include <string>


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