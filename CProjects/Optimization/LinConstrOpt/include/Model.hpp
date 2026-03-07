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

  BuildStatus buildStatus;

  void buildConstraint(const std::vector<double> &coefs, std::vector<Var> &vars,
                       const OperatorType &op, const double &bound) {
    
    LinearConstraint lc = ::buildConstraint(coefs, vars, op, bound);
    addConstraint(lc);
  }

  void buildObjective(const std::vector<double> &coefs, std::vector<Var> &vars,
                      const ObjectiveType &oType) {
    Objective obj;
    obj.buildObjective(coefs, vars, oType);
    addObjective(obj);
  }

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
    int lessThanCnt = 0;
    int greaterThanCnt = 0;
    int equalToCnt = 0;
    int negativeBoundsCnt = 0;
    for (auto &[constrName, constr] : constraints) {
      switch (constr.getOperatorType()) {
      case OperatorType::LessThan: {
        Var slack = Var(VariableType::Slack);
        constr.addValidVar(1.0, slack);
        varLookup.insert(slack.name);
        varRegister.push_back(slack);
        if(constr.getBound()) ++negativeBoundsCnt;
        ++lessThanCnt;
        break;
      }
      case OperatorType::GreaterThan: {
        Var surplus = Var(VariableType::Surplus);
        constr.addValidVar(-1.0, surplus);
        varLookup.insert(surplus.name);
        varRegister.push_back(surplus);
        if(constr.getBound()) ++negativeBoundsCnt;
        ++greaterThanCnt;
        break;
      }
      case OperatorType::EqualTo:
        ++equalToCnt;
        break;
      }
      row++;
    }
    int M = lessThanCnt + greaterThanCnt + equalToCnt;
    if (lessThanCnt == M){
      if(negativeBoundsCnt == 0){
        buildStatus = BuildStatus::FeasibleSolution;
        return buildStatus;
      }
    }
    buildStatus = BuildStatus::Success;
    return buildStatus;
  }

  Eigen::MatrixXd getCoefMatrix() const {
    if(buildStatus != BuildStatus::FeasibleSolution && buildStatus != BuildStatus::Success){
      throw std::invalid_argument("The model must be built successfully to return the coefficient matrix.");
    }
    for ( auto &[constrName, constr] : constraints ) {
      
    }
  }

private:
  int varCnt = 0;
  std::map<std::string, LinearConstraint> constraints;
  std::unordered_set<std::string> varLookup;
  std::vector<Var> varRegister;
  Objective objective;
  bool objectiveSet = false;
  int twoPhaseModel = true;

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