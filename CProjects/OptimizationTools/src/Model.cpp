
#include "Model.hpp"
using namespace std;

std::ostream &operator<<(std::ostream &os, const Var &v) {
  os << v.name;
  return os;
}

std::ostream &operator<<(std::ostream &os, const Model &m) {
  os << "Objective:\n  " << m.getObjective();
  os << "\nConstraints:\n";
  for (const auto &[name, constraint] : m.getConstraints()) {
    os << "  " << constraint;
  }
  return os;
}

