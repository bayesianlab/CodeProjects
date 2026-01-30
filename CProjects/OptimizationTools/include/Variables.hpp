
#pragma once
#ifndef VARIABLES_HPP
#define VARIABLES_HPP

#define VARS

#include "enums.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <map>
#include <string>
#include <vector>

struct Var {
  std::string name;
  Var() : name(defaultName + std::to_string(++instanceCnt)) {}
  Var(std::string n) : name(n) { ++instanceCnt; }
  Var(VariableType vt)
      : name(defaultName + std::to_string(++instanceCnt)), variableType(vt) {}
  static void setDefaultName(const std::string &n) { defaultName = n; }
  static void resetCounter(int value = -1) { instanceCnt = value; }
  const VariableType &getVariableType() const { return variableType; }
  void setVariableType(const VariableType &vt) { variableType = vt; }
  const bool &getBasisVar() const { return basisVar; }
  void setBasisVar(bool tf) { basisVar = tf; }
  bool operator==(const Var &other) const { return name == other.name; }
  bool operator<(const Var &other) const { return name < other.name; }

private:
  VariableType variableType;
  inline static std::string defaultName = "x";
  inline static int instanceCnt = -1;
  bool basisVar = false;
};

// Hash function for Var (required for std::unordered_map)
namespace std {
template <> struct hash<Var> {
  size_t operator()(const Var &v) const { return hash<string>()(v.name); }
};
} // namespace std

#endif