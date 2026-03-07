#include <Eigen/Dense>

#include "Distributions.hpp"

class SURTestData {
public:
  Eigen::MatrixXd yt;
  Eigen::MatrixXd Xt;
  Eigen::MatrixXd Sigma;
  Eigen::MatrixXd epsilon;
  Eigen::RowVectorXd predictors;

  void setRowEquations(int n) { rowEquations = n; }

  void setNumObservations(int n) { numObservations = n; }

  void setPredictorsPerEquation(int n) { predictorsPerEquation = n; }

  SURTestData(int K, int T, int p)
      : rowEquations(K), numObservations(T), predictorsPerEquation(p) {
    Xt = unifrnd(-1, 1, K * T, p);
    predictors = unifrnd(-1, 1, K * p);
    yt = Eigen::MatrixXd::Zero(K, T);
    epsilon = mvnrnd(K, T).transpose();
    Sigma = Eigen::MatrixXd::Identity(K, K);
  }

  void generate() {

    Eigen::MatrixXd surX = surForm(Xt, rowEquations);
    Eigen::MatrixXd Xbeta = (surX * predictors.transpose());

    yt = Xbeta.reshaped(rowEquations, numObservations) + epsilon;
  }

private:
  int rowEquations;
  int numObservations;
  int predictorsPerEquation;
};