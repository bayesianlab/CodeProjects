#include "Dist.hpp"
#include "timeseries.hpp"
#include <Eigen/Dense>
#include <unsupported/Eigen/KroneckerProduct>
#include <math.h>
#include <stdio.h>

using namespace std;
using namespace Eigen;

void TimeSeries::lagvars(MatrixXd &Xt, const Ref<const MatrixXd> &Yt, int lag) {
  int C = Yt.cols();
  VectorXd constant = MatrixXd::Ones(Xt.rows(), 1);
  for (int i = 0; i < lag; i++) {
    Xt.block(0, C * i + 1, Xt.rows(), C) = Yt.block(i, 0, Xt.rows(), C);
  }
  Xt.col(0) = constant;
}

MatrixXd TimeSeries::VAR(const MatrixXd &Yt, int lag) { 
	int N = Yt.rows() - lag;
	int C = Yt.cols();
	MatrixXd Xt(N, C*lag+1);
	lagvars(Xt, Yt, lag);
	MatrixXd Phi(C*lag + 1 , C);
	for(int c = 0; c < C; c++){
		Phi.col(c) = Xt.jacobiSvd(ComputeThinU | ComputeThinV).solve(Yt.bottomRows(N).col(c));
	}
	return Phi;
}

VectorXd TimeSeries::calcSigmaHatSqd(const MatrixXd &Yt, int lag) {
  int N = Yt.rows() - lag;
  int C = Yt.cols();
  MatrixXd Xt(N, lag + 1);
  MatrixXd I = MatrixXd::Identity(N, N);
  VectorXd sigmas(C);
  for (int c = 0; c < C; c++) {
    lagvars(Xt, Yt.col(c), lag);
    sigmas(c) = (Yt.col(c).bottomRows(N).transpose() *
                 (I - Xt * (Xt.transpose() * Xt).inverse() * Xt.transpose()) *
                 Yt.col(c).bottomRows(N)).value() /
                N;
      }
  return sigmas;
}

VectorXd TimeSeries::CreateScaledVarDiag(const MatrixXd &Yt, int lag, int C, double Big) {
  VectorXd sigmas = calcSigmaHatSqd(Yt, lag);
  cout << "sigma info" << endl;
  cout << sigmas << endl;
  cout << sigmas(0)/sigmas(1) << endl;
  cout << sigmas(1) /sigmas(0) << endl;
  cout << endl;
  MatrixXd LambdaTheta(C, C);
  double lambda = 1;
  double theta = 5;
  LambdaTheta.fill(lambda * theta);
  VectorXd lambdaVector(C);
  lambdaVector.fill(lambda);
  LambdaTheta.diagonal() = lambdaVector;
  MatrixXd SigmaMat = MatrixXd::Ones(C,C).array().colwise() * sigmas.array();
  cout << SigmaMat << endl;
  SigmaMat = (SigmaMat.array() * SigmaMat.transpose().array().pow(-1)).eval();
  cout << SigmaMat << endl;
  cout << LambdaTheta << endl;
  SigmaMat = LambdaTheta.array() * SigmaMat.array();
  MatrixXd ScaledWithConst(C*lag + 1, C);
  ScaledWithConst.block(1,0,C*lag, C) = kroneckerProduct(MatrixXd::Ones(lag,1), SigmaMat);
  cout << ScaledWithConst << endl;
  ScaledWithConst.row(0).fill(Big);
  Map<VectorXd> v(ScaledWithConst.data(), ScaledWithConst.size());
  cout << "v" << endl;
  cout << v << endl;
  return v;
}


VectorXd TimeSeries::CreateLagDiag(int C, int lag, double Big) {
  int lagsTeqns = C * lag + 1;
  int eqnCnt = 0;
  int k = 0;
  VectorXd lagVector(lag);
  for (int i = 0; i < lag; i++) {
    lagVector(i) = i + 1;
  }
  VectorXd diag(lagsTeqns);
  diag(0) = Big;
  for (int i = 1; i < lagsTeqns; i++) {
    if (eqnCnt < C) {
      diag(i) = 1 / lagVector(k);
      eqnCnt++;
    } else {
      k++;
      diag(i) = 1 / lagVector(k);
      eqnCnt = 1;
    }
  }
  return kroneckerProduct(MatrixXd::Ones(C, 1), diag);
}

MatrixXd TimeSeries::MinnesotaPrior( const MatrixXd &Yt, int lag, int C){
  ArrayXd L = CreateLagDiag(C, lag, 100).array(); 
  cout << "L" << endl;
  cout << endl;
  cout << L << endl;
  ArrayXd ScaledVars = CreateScaledVarDiag(Yt, lag, C, 100).array();
  VectorXd LS = L*ScaledVars;
  return MatrixXd(LS.asDiagonal());
}

void TimeSeries::BVAR(const MatrixXd &Yt, int lag) {
  int N = Yt.rows() - lag;
  int C = Yt.cols();
  VectorXd constant = MatrixXd::Ones(N, 1);
  MatrixXd Xt(N, C * lag + 1);
  lagvars(Xt, Yt, lag);
  MatrixXd I = MatrixXd::Identity(N, N);
  MatrixXd SigmaU =
      (Yt.bottomRows(N).transpose() *
       (I - Xt * (Xt.transpose() * Xt).inverse() * Xt.transpose()) *
       Yt.bottomRows(N))
          .array() /
      N;
  SigmaU.fill(8);
  MatrixXd M =  MinnesotaPrior(Yt, lag, C);
  cout << M << endl;
}

