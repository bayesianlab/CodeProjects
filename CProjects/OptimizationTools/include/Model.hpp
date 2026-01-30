#pragma once

#ifndef MODEL
#define MODEL

#include "LinearConstraint.hpp"
#include "Objective.hpp"
#include <Eigen/Dense>
#include <map>
#include <stdexcept>
#include <unordered_set>
#include <utility>
#include <vector>

class Model {
public:
  Model() = default;

  // Add a pre-built constraint
  void addConstraint(const LinearConstraint &lc) {
    LinearConstraint copy = lc;
    addValidConstr(copy);
  }

  void addObjective(const Objective &j) {
    objective = j;
    objectiveSet = true;
  }

  const std::map<std::string, LinearConstraint> &getConstraints() const {
    return constraints;
  }

  const std::vector<Var> &getVarRegister() const { return varRegister; }

  const bool &getObjectiveSet() const { return objectiveSet; }

  const Objective &getObjective() const { return objective; }

  BuildStatus buildModel() {
    if (constraints.empty()) {
      DBG("Model must have constraints in order to call *.build()");
      return BuildStatus::NoConstraints;
    }

    if (!getObjectiveSet()) {
      DBG("Model must have an objective equation set.");
      return BuildStatus::NoObjective;
    }

    int row = 0;
    for (auto &[constrName, constr] : constraints) {
      switch (constr.getOperatorType()) {
      case OperatorType::LessThan: {
        Var slack = Var(VariableType::Slack);
        constr.addValidVar(1.0, slack);
        varLookup.insert(slack.name);
        varRegister.push_back(slack);
        break;
      }
      case OperatorType::GreaterThan: {
        Var surplus = Var(VariableType::Surplus);
        constr.addValidVar(-1.0, surplus);
        varLookup.insert(surplus.name);
        varRegister.push_back(surplus);
        break;
      }
      case OperatorType::EqualTo:
        break;
      }
      row++;
    }
    return BuildStatus::Success;
  }

private:
  int varCnt = 0;
  std::map<std::string, LinearConstraint> constraints;
  std::unordered_set<std::string> varLookup;
  std::vector<Var> varRegister;
  Objective objective;
  bool objectiveSet = false;

  void addValidConstr(LinearConstraint &lc) {
    if (!lc.isNameSet()) {
      lc.setName();
    }

    if (!lc.isValid()) {
      throw std::invalid_argument("Invalid constraint");
    }

    if (constraints.find(lc.getName()) != constraints.end()) {
      throw std::invalid_argument("Constraint " + lc.getName() +
                                  " already exists");
    }

    for (const auto &var_coef : lc.getConstraintVars()) {
      const auto &[var, coef] = var_coef;
      if (varLookup.insert(var.name).second) {
        ++varCnt;
        varRegister.push_back(var);
      }
    }

    constraints.insert({lc.getName(), lc});
  }
};

// Forward declaration only
std::ostream &operator<<(std::ostream &os, const Model &m);

std::vector<Var> buildVarVector(size_t N);

#endif