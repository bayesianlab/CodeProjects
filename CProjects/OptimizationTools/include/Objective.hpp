#pragma once
#ifndef OBJECTIVE_HPP
#define OBJECTIVE_HPP

#include "enums.hpp"
#include "Variables.hpp"
#include <Eigen/Dense>
#include <unordered_map>
#include <vector>

class Objective {
public:
  ObjectiveBuildStatus buildObjective(const std::vector<double> &coefs,
                                      const std::vector<Var> &vars,
                                      const ObjectiveType &oType) {
    if (vars.empty()) {
      return ObjectiveBuildStatus::NoVariables;
    }
    if (oType == ObjectiveType::Undefined) {
      return ObjectiveBuildStatus::UndefinedType;
    }
    if (coefs.size() != vars.size()) {
      return ObjectiveBuildStatus::SizeMismatch;
    }
    for (size_t i = 0; i < vars.size(); ++i) {
      if (objectiveEqn.find(vars[i]) != objectiveEqn.end()) {
        return ObjectiveBuildStatus::DuplicateVariable;
      }
      objectiveEqn.insert({vars[i], coefs[i]});
    }
    setObjectiveType(oType);
    return ObjectiveBuildStatus::Success;
  }

  void addValidVar(const double &coef, const Var &v) {
    if (objectiveEqn.find(v) != objectiveEqn.end()) {
      throw std::invalid_argument("Variable with name " + v.name +
                                  " already exists in objective");
    }
    objectiveEqn.insert({v, coef});
  }

  const std::unordered_map<Var, double> &getObjectiveEqn() const {
    return objectiveEqn;
  }

  const Eigen::VectorXd
  getCoefficients(const std::vector<Var> &varRegister) const {
    Eigen::VectorXd coefs(varRegister.size());
    int i = 0;
    for (const auto &var : varRegister) {
      auto it = objectiveEqn.find(var);
      if (it == objectiveEqn.end()) {
        coefs(i++) = 0.0;
      } else {
        coefs(i++) = it->second;
      }
    }
    return coefs;
  }

  const ObjectiveType &getObjectiveType() const { return objectiveType; }

  void setObjectiveType(const ObjectiveType &oType) { objectiveType = oType; }

  bool isValidObjective() const {
    if (objectiveType == ObjectiveType::Undefined && !objectiveEqn.empty()) {
      return true;
    }
    return false;
  }

  const std::vector<double> getObjectiveCoef() const {
    std::vector<double> coefs;
    for (const auto &pair : objectiveEqn) {
      coefs.push_back(pair.second);
    }
    return coefs;
  }

  const std::vector<Var> getObjectiveVars() const {
    std::vector<Var> vars;
    for (const auto &pair : objectiveEqn) {
      vars.push_back(pair.first);
    }
    return vars;
  }

private:
  ObjectiveType objectiveType = ObjectiveType::Min;
  std::unordered_map<Var, double> objectiveEqn;
};

// Forward declaration only
std::ostream &operator<<(std::ostream &os, const Objective &objective);

#endif  // OBJECTIVE_HPP