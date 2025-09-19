#pragma once
#ifndef VARS
#define VARS

#include <string>
#include <iostream>

struct Var {
  Var() = default;
  std::string name;
  double coef;

  Var(double c, std::string n) {
    name = n;
    coef = c;
  }

private:
  double value;
};

std::ostream& operator<<(std::ostream& os, const Var& v){
    os << v.coef << v.name << std::endl; 
    return os; 
}

#endif
