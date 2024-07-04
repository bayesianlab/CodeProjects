#include "Distributions.hpp"
#include "EigenTools.hpp"
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

// MatrixXd TriangularSolver(const MatrixXd &AAT, int cols) {
//   MatrixXd B= MatrixXd::Zero(AAT.rows(), cols);
//   for (int j = 0; j < cols; ++j) {
//     RowVectorXd r1 = B.row(j).segment(0, j);
//     for (int i = j; i < AAT.rows(); ++i) {
//       RowVectorXd r2 = B.row(i).segment(0, j);
//       double inner_prod = (r1.array() * r2.array()).sum();
//       if (i == j) {
//         B(i, j) = sqrt(AAT(i, j) - inner_prod);
//       } else {
//         B(i, j) = (AAT(i, j) - inner_prod)/B(j,j);
//       }
//     }
//   }
//   return B;
// }

class MVTNProbs {
public:
  double batch_prob=0; 
  double batch_var=0; 
  double crb(const RowVectorXd &mu, const MatrixXd &Sigma,
             const RowVectorXd &constraints, const int G, const int bn) {
    MatrixXd Sample;
    int K = Sigma.rows();
    // Main MCMC
    Sample = mvtnrnd(mu, constraints, mu, Sigma, G, bn);
    VectorXd zstar = Sample.rowwise().mean();
    double ordinate =
        logmvtn_conditional_pdf_freeze(Sample, 0, mu, Sigma, constraints);
    int ReducedRuns = mu.size() - 2;
    for (int r = 1; r <= ReducedRuns; ++r) {
      Sample =
          mvtnrnd_freeze(r, zstar.transpose(), mu, Sigma, constraints, G, bn);
      zstar = Sample.rowwise().mean();
      ordinate +=
          logmvtn_conditional_pdf_freeze(Sample, r, mu, Sigma, constraints);
    }
    MatrixXd zstar_end = zstar;
    ordinate += logmvtn_conditional_pdf_freeze(zstar_end, K - 1, mu, Sigma,
                                               constraints);
    return logmvnpdf(zstar_end.transpose(), mu, Sigma) - ordinate;
  }

  void batch_chib(const RowVectorXd &mu, const MatrixXd &Sigma,
                   const RowVectorXd &constraints, const int G, const int bn,
                   int batches) {
    VectorXd batch_results(batches);
    for (int b = 0; b < batches; ++b) {
      batch_results(b) = crb(mu, Sigma, constraints, G, bn);
    }
    batch_prob = batch_results.mean();
    batch_var = variance(batch_results, 1).value();
  }
};

int main() {
  cout << "scratch" << endl;

  // MatrixXd Sigma = .5*MatrixXd::Identity(4,4);
  // MatrixXd A = .25*MatrixXd::Ones(4, 2);
  // A.col(1) = .5 * A.col(0);
  // for (int i = 0; i < A.rows(); ++i) {
  //   for (int j = 0; j < A.cols(); ++j) {
  //     if(j==i){
  //       A(i,j) = sqrt(1./2.0);
  //     }
  //     if (j > i) {
  //       A(i, j) = 0;
  //     }
  //   }
  // }
  // cout << A << endl;
  // MatrixXd C = A*A.transpose() + Sigma;
  // MatrixXd D = C.diagonal().array().pow(-.5);
  // MatrixXd Z = D.asDiagonal();
  // C = Z*C*Z;
  // C = C - Sigma;
  // MatrixXd AAT = A*A.transpose();
  // MatrixXd Y = TriangularSolver(C, A.cols());
  // MatrixXd U = Z*Y;
  // cout << U*U.transpose() + Sigma << endl;

  // MatrixXd P = normrnd(0,1, 10, 1);
  // cout << endl;
  // cout << P << endl;
  // P.transpose().resize(5,2);
  // cout << P << endl;

  int J = 6;
  MatrixXd Sig1 = CreateSigma(-.7, J);
  RowVectorXd mu = RowVectorXd::Zero(J);
  RowVectorXd orthant = RowVectorXd::Ones(J);
  mu(0) = 0;
  mu(1) = 0.5;
  mu(2) = 1;
  mu(3) = 0;
  mu(4) = .5;
  mu(5) = 1; 
  // cout << crb(mu, Sig1, orthant, 100, 10) << endl;
  MVTNProbs probs; 
  probs.batch_chib(mu, Sig1, orthant, 100, 10, 100);
  cout << probs.batch_prob << endl; 
  cout << probs.batch_var << endl; 
}