#pragma once
#ifndef LINEAR_CONSTRAINT_HPP
#define LINEAR_CONSTRAINT_HPP

#include "debug.hpp"
#include "enums.hpp"
#include "Variables.hpp"
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

class LinearConstraint {
public:
  LinearConstraint() : myId(++instanceCnt) {}
  LinearConstraint(std::string _name) : name(_name), myId(++instanceCnt) {}

  void buildConstraint(const std::vector<double> &coefs,
                       const std::vector<Var> &vars, const OperatorType &op,
                       const double &bound) {
    if (coefs.size() != vars.size()) {
      throw std::invalid_argument(
          "Number of coefs must be the same as the number of variables.");
    }
    for (size_t i = 0; i < vars.size(); ++i) {
      addValidVar(coefs[i], vars[i]);
    }
    addBound(bound);
    addOperator(op);
  }

  void addBound(const double &b) {
    bound = b;
    boundSet = true;
  }

  void addOperator(const OperatorType &op) {
    operatorType = op;
    operatorSet = true;
  }

  bool isValid() const {
    if (!operatorSet) {
      DBG("Operator is not set in constraint " + name);
      return false;
    }
    if (!boundSet) {
      DBG("Bound is not set in constraint " + name);
      return false;
    }
    return true;
  }

  void setName() {
    name = defaultName + std::to_string(myId);
    nameSet = true;
  }
  void setName(std::string _name) {
    name = _name;
    nameSet = true;
  }

  bool isNameSet() const { return nameSet; }
  bool isOperatorSet() const { return operatorSet; }
  bool isBoundSet() const { return boundSet; }

  const std::unordered_map<Var, double> &getConstraintVars() const {
    return constraintVars;
  }
  const std::string &getName() const { return name; }
  const OperatorType &getOperatorType() const { return operatorType; }
  const double &getBound() const { return bound; }

  void resetCnt() { instanceCnt = -1; }

  void addValidVar(const double &coef, const Var &v) {
    if (constraintVars.find(v) != constraintVars.end()) {
      throw std::invalid_argument("Variable with name " + v.name +
                                  " already exists in constraint");
    }
    Var varCopy = v;
    varCopy.setVariableType(VariableType::Control);
    constraintVars.insert({varCopy, coef});
  }

  LinearConstraint operator-() const {
    LinearConstraint result = *this; // Copy this constraint
    for (auto &[k, v] : result.constraintVars) {
      v = -v;
    }
    result.bound = -result.bound;
    result.operatorType = -result.operatorType;
    return result;
  }

private:
  std::string defaultName = "constr_";
  std::unordered_map<Var, double> constraintVars;
  std::string name;
  OperatorType operatorType;
  double bound;
  bool operatorSet = false;
  bool boundSet = false;
  bool nameSet = false;
  int myId; // Store this instance's ID
  inline static int instanceCnt = -1;
};

// Declaration - definition in LinearConstraint.cpp
std::ostream &operator<<(std::ostream &os, const LinearConstraint &lc);

LinearConstraint buildConstraint(const std::vector<double> &coefs,
                                 const std::vector<Var> &vars,
                                 const OperatorType &op, const double &bound);

#endif // LINEAR_CONSTRAINT_HPP