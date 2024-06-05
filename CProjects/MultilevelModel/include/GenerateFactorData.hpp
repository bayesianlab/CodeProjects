#pragma once
#ifndef DGPML_H
#define DGPML_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <unsupported/Eigen/KroneckerProduct>

#include "Distributions.hpp"
#include "MultilevelModelFunctions.hpp"

using namespace Eigen;
using namespace std;

class GenerateFactorData {
  /* betas will be same for every equation,
  X should be stacked over T
  gammas should include greatest lag in 0th column, stacked over equations
  loadings should be a matrix equaling the number of equaitons in the row
  dimension factors will be nFactors = rows time = cols */
 public:
  int T;
  int K;
  int nFactors;
  int nEqnsP;
  VectorXd betas;
  MatrixXd Xt;
  MatrixXd surX;
  VectorXd allBetas;
  MatrixXd Xbeta;
  MatrixXd Identity;
  MatrixXd gammas;
  VectorXd factorVariances;
  MatrixXd Loadings;
  MatrixXd P0;
  MatrixXd FactorPrecision;
  MatrixXd Factors;
  MatrixXd AF;
  MatrixXd mu;
  MatrixXd epsilon;
  MatrixXd yt;
  VectorXd om_variance;
  VectorXd om_precision;
  MatrixXd b0;
  MatrixXd B0;
  RowVectorXd g0;
  MatrixXd G0;
  MatrixXd H;
  MatrixXd resids;
  MatrixXd deltas;
  // For KOW model
  void genDataArErrors(const int &nObs, const int &nEqns, const int &nXs,
                       const double &coeffValues,
                       const Matrix<int, Dynamic, 2> &InfoMap,
                       const RowVectorXd &gammas, const RowVectorXd &omArTerms,
                       const double &omVar);

  pair<MatrixXd, MatrixXd> AstarLstar(const MatrixXd &A, const MatrixXd &Sigma);

  void genData(int _nEqns, int _nObs, int nbetas, int ngammas,
               const Matrix<int, Dynamic, 2> &InfoMat);

  void setLoadings(const Ref<const MatrixXd> &A,
                   const Matrix<int, Dynamic, 2> &InfoMat, MatrixXd &Identity,
                   double restriction) {
    int nFactors = InfoMat.rows();
    Loadings = A;
    int c = 0;
    for (int i = 0; i < nFactors; ++i) {
      Loadings(InfoMat.row(i).head(1).value(), i) = restriction;
      ++c;
    }
    Loadings = Identity.array() * Loadings.array();
  }

  void breakPointGenData(int Time, int nEqns, int nbetas,
                         const Matrix<int, Dynamic, 2> &InfoMat, int breakpoint,
                         double loadingMag);

  void genProbitData(int _K, int _T, int nbetas, int ngammas,
                     const Matrix<int, Dynamic, 2> &InfoMat);

};
#endif
