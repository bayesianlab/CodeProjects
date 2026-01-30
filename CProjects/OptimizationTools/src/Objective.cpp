
#include "Objective.hpp"
#include "Variables.hpp"
#include <iostream>
#include <vector>
using namespace std;

std::ostream &operator<<(std::ostream &os, const Objective &objective) {
  auto N = objective.getObjectiveEqn().size();
  const auto &coef = objective.getObjectiveCoef();
  size_t i = 0;
  os << toString(objective.getObjectiveType()) << " ";
  for (const auto &var : objective.getObjectiveVars()) {
    if (i < N - 1) {
      os << coef[i] << var.name << " + ";
    } else {
      os << coef[i] << var.name;
    }
    i++;
  }
  os << "\n";
  return os;
}

