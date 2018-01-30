#include "CreateSampleData.hpp"
#include <Eigen/Dense>
#include <iostream>
#include <math.h>

using namespace std;
using namespace Eigen;

CreateSampleData::CreateSampleData(int sampleSize, VectorXd &betas) {
  dimension = betas.size();
  X = normrnd(0, 3, sampleSize, dimension);
  epsilon = normrnd(0, 3, sampleSize);
  y = X * betas + epsilon;
  MatrixXd XpX = X.transpose() * X;
  MatrixXd XpXinv = XpX.inverse();
  MatrixXd Xpy = X.transpose() * y;
  mles = XpXinv * Xpy;
  resids = y - X * mles;
  residsTresids = resids.transpose() * resids;
  sigmaSqdHat = residsTresids / sampleSize;
  inverseFisher = MatrixXd::Zero(dimension + 1, dimension + 1);
  inverseFisher(0, 0) = 2 * pow(sigmaSqdHat, 2) / sampleSize;
  inverseFisher.block(1, 1, dimension, dimension) = sigmaSqdHat * XpXinv;
  maxLikeEsts = VectorXd::Zero(dimension + 1);
  maxLikeEsts << sigmaSqdHat, mles;
}
CreateSampleData::CreateSampleData(int sampleSize, VectorXd &betas, int s) {
  rseed.seed(s);
  dimension = betas.size();
  X = normrnd(0, 1, sampleSize, dimension);
  epsilon = normrnd(0, 1, sampleSize);
  y = X * betas + epsilon;
  MatrixXd XpX = X.transpose() * X;
  MatrixXd XpXinv = XpX.inverse();
  MatrixXd Xpy = X.transpose() * y;
  mles = XpXinv * Xpy;
  resids = y - X * mles;
  residsTresids = resids.transpose() * resids;
  sigmaSqdHat = residsTresids / sampleSize;
  inverseFisher = MatrixXd::Zero(dimension + 1, dimension + 1);
  inverseFisher(0, 0) = 2 * pow(sigmaSqdHat, 2) / sampleSize;
  inverseFisher.block(1, 1, dimension, dimension) = sigmaSqdHat * XpXinv;
  maxLikeEsts = VectorXd::Zero(dimension + 1);
  maxLikeEsts << sigmaSqdHat, mles;
}

CreateSampleData::CreateSampleData(int sampleSize, VectorXd &betas,
                                   int withconsant, double sigma2, int s) {
  rseed.seed(s);
  dimension = betas.size();
  MatrixXd x = normrnd(0, 1, sampleSize, dimension- 1);
  VectorXd c = MatrixXd::Ones(sampleSize, 1);
  X = MatrixXd::Zero(sampleSize, dimension );
  X << c, x;
  epsilon = normrnd(0, sqrt(sigma2), sampleSize);
  y = X * betas + epsilon;
  MatrixXd XpX = X.transpose() * X;
  MatrixXd XpXinv = XpX.inverse();
  MatrixXd Xpy = X.transpose() * y;
  mles = XpXinv * Xpy;
  resids = y - X * mles;
  residsTresids = resids.transpose() * resids;
  sigmaSqdHat = residsTresids / sampleSize;
  inverseFisher = MatrixXd::Zero(dimension + 1, dimension + 1);
  inverseFisher(0, 0) = 2 * pow(sigmaSqdHat, 2) / sampleSize;
  inverseFisher.block(1, 1, dimension, dimension) = sigmaSqdHat * XpXinv;
  maxLikeEsts = VectorXd::Zero(dimension + 1);
  maxLikeEsts << sigmaSqdHat, mles;
}

CreateSampleData::CreateSampleData(int sampleSize, VectorXd &betas,
                                   int withconsant, double sigma2) {
  dimension = betas.size();
  MatrixXd x = normrnd(0, 1, sampleSize, dimension- 1);
  VectorXd c = MatrixXd::Ones(sampleSize, 1);
  X = MatrixXd::Zero(sampleSize, dimension );
  X << c, x;
  epsilon = normrnd(0, sqrt(sigma2), sampleSize);
  y = X * betas + epsilon;
  MatrixXd XpX = X.transpose() * X;
  MatrixXd XpXinv = XpX.inverse();
  MatrixXd Xpy = X.transpose() * y;
  mles = XpXinv * Xpy;
  resids = y - X * mles;
  residsTresids = resids.transpose() * resids;
  sigmaSqdHat = residsTresids / sampleSize;
  inverseFisher = MatrixXd::Zero(dimension + 1, dimension + 1);
  inverseFisher(0, 0) = 2 * pow(sigmaSqdHat, 2) / sampleSize;
  inverseFisher.block(1, 1, dimension, dimension) = sigmaSqdHat * XpXinv;
  maxLikeEsts = VectorXd::Zero(dimension + 1);
  maxLikeEsts << sigmaSqdHat, mles;
}
