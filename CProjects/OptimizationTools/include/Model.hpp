#pragma once
#ifndef MODEL
#define MODEL

#include "Variables.hpp"
#include <map>
#include <utility>
#include <vector>

using namespace std; 

class Model {

public:
  std::map<string, Var> Variables;
  Model() {};
  void addVariable(const double &coef, const string &name) {
    Variables.emplace(std::piecewise_construct, std::forward_as_tuple(name),
                      std::forward_as_tuple(coef, name));
  }

  vector<string> defineConstraint(vector<string> &names){
    vector<Var> constraintKeys; 
    for(const auto &key : names){
        auto it = Variables.find(key);
        if(it != Variables.end()){
            constraintKeys.push_back(it->second);
        }
        else{
            throw runtime_error("Key not found in defineConstraint.");
        }
    }
  }
};

#endif