// Debug.hpp
#pragma once

#include <iostream>

#ifndef NDEBUG
#define DBG(x) std::cout << x << "\n"
#else
#define DBG(x)
#endif

// Enums.hpp
#pragma once

#ifndef ENUMS_HPP
#define ENUMS_HPP

#include <string>

enum class OperatorType { LessThan, GreaterThan, EqualTo };

inline OperatorType operator-(OperatorType op) {
switch (op) {
case OperatorType::LessThan: return OperatorType::GreaterThan;
case OperatorType::GreaterThan: return OperatorType::LessThan;
case OperatorType::EqualTo: return OperatorType::EqualTo;
}
return op; // Default fallback
}

enum class OptimizationStatusType { Success, Unbounded, Infeasible, Unknown };

enum class VariableType { Control, Artificial, Surplus, Slack };

enum class ObjectiveType { Min, Max, Undefined };

enum class BuildStatus {
FeasibleSolution,
Success,
NoConstraints,
NoObjective,
InvalidConstraint
};




enum class ObjectiveBuildStatus {
Success,
NoVariables,
UndefinedType,
SizeMismatch,
DuplicateVariable
};

std::string toString(OperatorType op);
std::string toString(ObjectiveType obj);


inline std::string toString(OperatorType op) {
  switch (op) {
  case OperatorType::LessThan:
    return "<=";
  case OperatorType::GreaterThan:
    return ">=";
  case OperatorType::EqualTo:
    return "==";
  }
  return "Unknown";
}

inline std::string toString(ObjectiveType ot) {
  switch (ot) {
  case ObjectiveType::Min:
    return "minimize";
  case ObjectiveType::Max:
    return "maximize";
  case ObjectiveType::Undefined:
    return "undefined";
  }
  return "Unknown";
}

#endif