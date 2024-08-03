#pragma once
#ifndef VAR_H
#define VAR_H
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <unsupported/Eigen/KroneckerProduct>
#include "Distributions.hpp"
#include "TimeSeriesTools.hpp"

using namespace Eigen; 
using namespace std;

class VarData {
private:
  int K, T, p;

public:
  MatrixXd Beta;
  MatrixXd yt;
  VarData(int _K, int _T, int _p) {
    K = _K;
    T = _T;
    p = _p;
    Beta.resize(K, (p * K) );
    yt.resize(K, T); 
  }


  void coefs(double value) {
    MatrixXd Gamma(K, K);
    Gamma.setZero();
    for (int k = 0; k < K; ++k) {
      double b = value;
      for (int j = 0; j < K; ++j) {
        Gamma(k, j) = b * (pow(-.5, j));
      }
    }
    for (int c = 0; c < p; ++c) {
      if (c == 0) {
        Beta.block(0, (K * c) , K, K) = Gamma.array();
      } else {
        Beta.block(0, (K * c), K, K) =
            Beta.block(0, (K * (c-1)) , K, K).array() * value;
      }
    }
  }

  template<typename T> 
  void cycle(MatrixBase<T> &Y, const VectorXd &y){
    int J = Y.rows(); 
    MatrixXd tmp = Y.block(0,0, J, Y.cols()-1); 
    Y.col(0) = y; 
    Y.block(0,1, J, Y.cols()-1) = tmp; 
  }

  template<typename T>
  void StateSpace(const MatrixBase<T> &B){
    // Does not include a constant 
    int K = B.rows(); 
    int p = B.cols()/K; 
    MatrixXd I = MatrixXd::Identity(K*(p-1), K*(p-1));
    MatrixXd Z = MatrixXd::Zero(K*(p-1), K);
    MatrixXd F(K*p, K*p); 
    F.block(0,0,K, K*p) = B; 
    F.block(K,0, K*(p-1), K*(p-1)) = I; 
    F.block(K, K*(p-1), Z.rows(), Z.cols()) = Z; 
    auto eg = F.eigenvalues();
    ArrayXd real_eigs = eg.real();
    if (real_eigs.any() > 1){
      cout << "Warning: eigen values of coefficients greater than 1" << endl; 
    }
  }

  void generate(double value) {
    coefs(value);
    StateSpace(Beta.block(0,0, Beta.rows(), Beta.cols())); 
    yt.block(0,0,K, p) = normrnd(0,1,K,p);
    MatrixXd X = yt.block(0,0,K, p); 
    MatrixXd c = -value*VectorXd::Ones(K); 

    for(int t = p; t < T; ++t){
        X.resize(K*p, 1);
        VectorXd y = c + Beta*X + normrnd(0,1, K); 
        yt.col(t) = y; 
        X.resize(K, p);
        cycle(X, y); 
    } 
      cout << yt << endl; 
  }
};

#endif