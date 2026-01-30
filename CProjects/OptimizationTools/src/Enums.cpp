#include "enums.hpp"

std::string toString(OperatorType op) {
  switch (op) {
  case OperatorType::LessThan:
    return "<=";
  case OperatorType::GreaterThan:
    return ">=";
  case OperatorType::EqualTo:
    return "==";
  default:
    return "Unknown";
  }
}

std::string toString(ObjectiveType obj) {
  switch (obj) {
  case ObjectiveType::Min:
    return "minimize";
  case ObjectiveType::Max:
    return "maximize";
  default:
    return "Unknown";
  }
}
