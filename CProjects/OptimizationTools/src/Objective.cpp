
#include "Objective.hpp"
#include "Variables.hpp"
#include <iostream>
#include <vector>
using namespace std;

std::ostream &operator<<(std::ostream &os, const Objective &objective) {
  const auto &varRegister = objective.getVarRegister();
  const auto &eqn = objective.getObjectiveEqn();
  
  os << toString(objective.getObjectiveType()) << " ";
  for (size_t i = 0; i < varRegister.size(); ++i) {
    auto it = eqn.find(varRegister[i]);
    if (it != eqn.end()) {
      if (i < varRegister.size() - 1) {
        os << it->second << varRegister[i].name << " + ";
      } else {
        os << it->second << varRegister[i].name;
      }
    }
  }
  os << "\n";
  return os;
}
