
#include "Model.hpp"
#include "LinearConstraint.hpp"
#include "gtest/gtest.h"
#include <iostream>
using namespace std;

TEST(ConstraintValidation, BasicConstraint) {
  std::vector<Var> v1 = buildVarVector(1);
  std::vector<double> c1 = {1};
  LinearConstraint lc = buildConstraint(c1, v1, OperatorType::LessThan, 10.5);
  EXPECT_TRUE(lc.isValid());
}

TEST(ConstraintValidation, MultiVarConstraint) {
  std::vector<Var> vars = buildVarVector(3);
  std::vector<double> coefs = {1, 3, 2};
  LinearConstraint lc = buildConstraint(coefs, vars, OperatorType::LessThan, 3.4);
  EXPECT_TRUE(lc.isValid());
  EXPECT_EQ(lc.getBound(), 3.4);
}

TEST(ObjectiveValidation, BasicObjective) {
  std::vector<Var> vars = buildVarVector(3);
  std::vector<double> objCoefs = {4, 5, 2};
  Objective obj;
  ObjectiveBuildStatus status = obj.buildObjective(objCoefs, vars, ObjectiveType::Max);
  EXPECT_EQ(status, ObjectiveBuildStatus::Success);
}

TEST(ModelValidation, AddConstraintsAndObjective) {
  std::vector<Var> vars = buildVarVector(3);
  std::vector<double> coefs = {1, 3, 2};
  std::vector<double> coefs2 = {2, 1, 1};
  std::vector<double> objCoefs = {4, 5, 2};
  
  LinearConstraint l1 = buildConstraint(coefs, vars, OperatorType::LessThan, 3.4);
  LinearConstraint l2 = buildConstraint(coefs2, vars, OperatorType::LessThan, 2.0);
  
  Objective obj;
  obj.buildObjective(objCoefs, vars, ObjectiveType::Max);
  
  Model m;
  m.addConstraint(l1);
  m.addConstraint(l2);
  m.addObjective(obj);
  
  // Build the model (this will initialize slack variables, etc)
  BuildStatus buildStatus = m.buildModel();
  EXPECT_NE(buildStatus, BuildStatus::InvalidConstraint);
}
