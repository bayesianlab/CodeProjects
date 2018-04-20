#include "timeseries.hpp"
#include "Dist.hpp"
#include <Eigen/Dense>
#include <math.h>
#include <stdio.h>
#include <unsupported/Eigen/KroneckerProduct>

using namespace std;
using namespace Eigen;

void TimeSeries::lagvars(MatrixXd &Xt, const Ref<const MatrixXd> &Yt, int lag) {
  int C = Yt.cols();
  VectorXd constant = MatrixXd::Ones(Xt.rows(), 1);
  for (int i = 0; i < lag; i++) {
    Xt.block(0, C * i + 1, Xt.rows(), C) =
        Yt.block((lag - 1) - i, 0, Xt.rows(), C);
  }
  Xt.col(0) = constant;
}

MatrixXd TimeSeries::VAR(const MatrixXd &Yt, int lag) {
  int N = Yt.rows() - lag;
  int C = Yt.cols();
  MatrixXd Xt(N, C * lag + 1);
  lagvars(Xt, Yt, lag);
  MatrixXd Phi(C * lag + 1, C);
  for (int c = 0; c < C; c++) {
    Phi.col(c) = Xt.jacobiSvd(ComputeThinU | ComputeThinV)
                     .solve(Yt.bottomRows(N).col(c));
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
                 Yt.col(c).bottomRows(N))
                    .value() /
                N;
  }
  return sigmas;
}

MatrixXd TimeSeries::CreateMinnesotaPrior(const MatrixXd &Yt, int lag,
                                          double lambda0, double lambda1,
                                          double theta) {
  int K = Yt.cols();
  VectorXd sigmas = calcSigmaHatSqd(Yt, lag);
  MatrixXd LambdaTheta(K, K);
  LambdaTheta.fill(lambda1 * theta);
  LambdaTheta.diagonal().fill(lambda1);
  RowVectorXd LagVec(lag);
  for (int i = 0; i < lag; i++) {
    LagVec(i) = 1. / (i + 1);
  }
  MatrixXd SigmaMat = MatrixXd::Ones(K, K).array().colwise() * sigmas.array();
  SigmaMat = (SigmaMat.array() * SigmaMat.transpose().array().pow(-1)).eval();
  MatrixXd MinnDiag(K, lag * K + 1);
  MinnDiag.block(0, 1, K, lag * K) =
      kroneckerProduct(MatrixXd::Ones(1, SigmaMat.cols()), SigmaMat).array() *
      kroneckerProduct(LagVec, LambdaTheta).array();
  MinnDiag.col(0).fill(lambda0);
  Map<VectorXd> d(MinnDiag.data(), MinnDiag.size());
  d = d.array() * d.array();
  return d.asDiagonal();
}

void TimeSeries::BvarMinnesota(const MatrixXd &Yt, int lag,
                               double constantShrinkage, double totalShrinkage,
                               double otherShrinkage, int Sims, int burn) {
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
       N)
          .matrix()
          .inverse();
  MatrixXd Minv = CreateMinnesotaPrior(Yt, lag, constantShrinkage,
                                       totalShrinkage, otherShrinkage)
                      .inverse();
  MatrixXd XtTXt = Xt.transpose() * Xt;
  MatrixXd YtT = Yt.bottomRows(N).transpose();
  Map<const VectorXd> vecY(YtT.data(), YtT.size());
  MatrixXd alphaMat = MatrixXd::Zero(Minv.rows(), Sims - burn);
  VectorXd alphaBar = MatrixXd::Zero(Minv.rows(), 1);
  VectorXd alphaNew = MatrixXd::Zero(Minv.rows(), 1);
  MatrixXd MinnUpdate = (Minv + kroneckerProduct(XtTXt, SigmaU)).inverse();
  int c = 0;
  for (int i = 0; i < Sims; i++) {

    alphaBar = MinnUpdate * (Minv * alphaNew +
                             kroneckerProduct(Xt, SigmaU).transpose() * vecY);

    alphaNew = mvnrnd(alphaBar, MinnUpdate, 1).transpose();
    if (i > burn) {
      alphaMat.col(c) = alphaNew;
      c++;
    }
  }
  MatrixXd Coefs = alphaMat.transpose().colwise().mean();
  Map<MatrixXd> coefMat(Coefs.data(), C, C * lag + 1);
  cout << coefMat.transpose() << endl;
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
  MatrixXd SigmaU = MatrixXd::Identity(C, C);
  MatrixXd Vupbar = (VlowbarInv + XtTXt).inverse();
  MatrixXd alphaupbar = MatrixXd::Zero(XtTXt.rows(), 1);
  VectorXd alphalowbar = MatrixXd::Zero(C * lag * (C + 1), 1);
  MatrixXd SigmaA = MatrixXd::Identity(C * (lag + 1), C * (lag + 1));
  Map<MatrixXd> Alowbar(alphalowbar.data(), C * lag + 1, C);
  MatrixXd Aupbar = Vupbar * (Alowbar + Xt.transpose() * Yt.bottomRows(N));
  MatrixXd Supbar = SigmaU;
  int vlowbar = C;
  int vupbar = vlowbar + N;
  int burn = .1 * Sims;
  MatrixXd A(Sims - burn, alphalowbar.size());
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

