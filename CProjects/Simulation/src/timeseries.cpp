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
    Xt.block(0, C * i + 1, Xt.rows(), C) = Yt.block((lag-1) - i, 0, Xt.rows(), C);
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

VectorXd TimeSeries::CreateScaledVarDiag(const MatrixXd &Yt, int lag, int C,
                                         double lambda0, double lambda1,
                                         double theta) {
  VectorXd sigmas = calcSigmaHatSqd(Yt, lag);
  MatrixXd LambdaTheta(C, C);
  LambdaTheta.fill(lambda1 * theta);
  VectorXd lambda1Vector(C);
  lambda1Vector.fill(lambda1);
  LambdaTheta.diagonal() = lambda1Vector;
  MatrixXd SigmaMat = MatrixXd::Ones(C,C).array().colwise() * sigmas.array();
  SigmaMat = LambdaTheta.array() * (SigmaMat.array() * SigmaMat.transpose().array().pow(-1)).eval();
  MatrixXd ScaledWithConst(C*lag + 1, C);
  ScaledWithConst.block(1,0,C*lag, C) = kroneckerProduct(MatrixXd::Ones(lag,1), SigmaMat);
  ScaledWithConst.row(0).fill(lambda0);
  Map<VectorXd> v(ScaledWithConst.data(), ScaledWithConst.size());
  return v;
}


VectorXd TimeSeries::CreateLagDiag(int C, int lag) {
  int lagsTeqns = C * lag + 1;
  int eqnCnt = 0;
  int k = 0;
  VectorXd lagVector(lag);
  for (int i = 0; i < lag; i++) {
    lagVector(i) = i + 1;
  }
  VectorXd diag(lagsTeqns);
  diag(0) = 1;
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
  ArrayXd L = CreateLagDiag(C, lag).array();
  ArrayXd ScaledVars = CreateScaledVarDiag(Yt, lag, C, 100, 1, 5).array();
  VectorXd LS = L*ScaledVars;
  return MatrixXd(LS.asDiagonal());
}

void TimeSeries::BvarMinnesota(const MatrixXd &Yt, int lag) {
  int N = Yt.rows() - lag;
  int C = Yt.cols();
  VectorXd constant = MatrixXd::Ones(N, 1);
  MatrixXd Xt(N, C * lag + 1);
  lagvars(Xt, Yt, lag);
  MatrixXd I = MatrixXd::Identity(N, N);
  MatrixXd SigmaU =
      ((Yt.bottomRows(N).transpose() *
       (I - Xt * (Xt.transpose() * Xt).inverse() * Xt.transpose()) *
       Yt.bottomRows(N))
          .array() /
      N).matrix().inverse();
  MatrixXd M =  MinnesotaPrior(Yt, lag, C).inverse();
  int Sims = 10;
  MatrixXd XtTXt = Xt.transpose() * Xt;
  MatrixXd YtT = Yt.bottomRows(N).transpose();
  Map<const VectorXd> vecY(YtT.data(), YtT.size());
  MatrixXd alphaBar(M.rows(),Sims);
  alphaBar.setZero();
  MatrixXd MinnUpdate(M.rows(), M.cols());
  for(int i = 0; i < Sims-1; i++){
    MinnUpdate = (M + kroneckerProduct(SigmaU, XtTXt)).inverse().eval();
    alphaBar.col(i) = M * (M * alphaBar.col(i) +
                           kroneckerProduct(SigmaU, Xt).transpose() * vecY);
    alphaBar.col(i + 1) = mvnrnd(alphaBar.col(i), MinnUpdate, 1).transpose();
  }
  cout << alphaBar.transpose() << endl;
}

void TimeSeries::BvarConjugate(const MatrixXd &Yt, int lag) {
  int N = Yt.rows() - lag;
  int C = Yt.cols();
  VectorXd constant = MatrixXd::Ones(N, 1);
  MatrixXd Xt(N, C * lag + 1);
  lagvars(Xt, Yt, lag);

  int Sims = 1000;
  MatrixXd XtTXt = Xt.transpose() * Xt;
  MatrixXd VlowbarInv =
      MatrixXd::Identity(XtTXt.rows(), XtTXt.cols()).inverse();
  MatrixXd YtT = Yt.bottomRows(N).transpose();
  Map<const VectorXd> vecY(YtT.data(), YtT.size());
  MatrixXd SigmaU = MatrixXd::Identity(C,C);
  MatrixXd Vupbar = (VlowbarInv +  XtTXt).inverse();
  MatrixXd alphaupbar = MatrixXd::Zero(XtTXt.rows(), 1);
  VectorXd alphalowbar = MatrixXd::Zero(C*lag*(C+1), 1);
  MatrixXd SigmaA = MatrixXd::Identity(C*(lag+1), C*(lag+1));
  Map<MatrixXd> Alowbar(alphalowbar.data(), C*lag + 1, C);
  MatrixXd Aupbar = Vupbar * (Alowbar + Xt.transpose() * Yt.bottomRows(N));
  MatrixXd Supbar = SigmaU;
  int vlowbar = C;
  int vupbar = vlowbar + N;
  int burn = .1*Sims;
  MatrixXd A(Sims-burn, alphalowbar.size());
  int store = 0;
  for (int i = 0; i < Sims; i++) {
    SigmaA = kroneckerProduct(VlowbarInv, SigmaU);
    Aupbar.resize(C * (C * lag + 1), 1);
    if (i >= burn) {
      A.row(store) = mvnrnd(Aupbar, SigmaA, 1);
	  store++;
	}
    Aupbar.resize(C * lag + 1, C);
    Supbar = SigmaU + (Yt.transpose() * Yt) +
             (Alowbar.transpose() * VlowbarInv * Alowbar) -
             (Aupbar.transpose() * Vupbar * Aupbar);
    SigmaU = wishartrnd(Supbar, vupbar).inverse();
      }
  cout << A.colwise().mean() << endl;
}

