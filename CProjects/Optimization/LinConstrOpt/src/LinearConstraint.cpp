#include "LinearConstraint.hpp"
#include "Variables.hpp"
#include <iostream>
#include <vector>
using namespace std;

std::ostream &operator<<(std::ostream &os, const LinearConstraint &lc) {
  const auto &vars = lc.getConstraintVars();
  const auto &coef_map = vars;
  size_t i = 0;
  size_t N = coef_map.size();
  for (const auto &[var, coef] : coef_map) {
    if (i < N - 1) {
      os << coef << var.name << " + ";
    } else {
      os << coef << var.name;
    }
    i++;
  }
  os << " " << toString(lc.getOperatorType()) << " " << lc.getBound() << "\n";
  return os;
}

LinearConstraint buildConstraint(const std::vector<double> &coefs,
                                 std::vector<Var> &vars,
                                 const OperatorType &op, const double &bound) {
  if (coefs.size() != vars.size()) {
    throw std::invalid_argument(
        "Number of coefs must be the same as the number of variables.");
  }
  LinearConstraint lc;
  for (size_t i = 0; i < vars.size(); ++i) {
    lc.addValidVar(coefs[i], vars[i]);
  }
  lc.addBound(bound);
  lc.addOperator(op);
  return lc;
}

