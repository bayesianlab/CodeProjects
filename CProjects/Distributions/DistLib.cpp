#include "DistLib.hpp"
#include <Eigen/src/Core/Matrix.h>
#include <random>

double Normal::sample() const { return dist(rng); }

void Normal::set_parameters(double mu, double sigma) {
  dist = std::normal_distribution<double>(mu, sigma);
}

void Normal::sample(Eigen::VectorXd &vec) {
  vec.noalias() = Eigen::VectorXd::NullaryExpr(
      vec.size(), [this]() { return this->dist(this->rng); });
}

void Normal::sample(Eigen::MatrixXd &mat) {
  mat.noalias() = Eigen::MatrixXd::NullaryExpr(
      mat.rows(), mat.cols(), [this]() { return this->dist(this->rng); });
}

double InverseGamma::sample() const {
  double g = dist(rng);
  return (g > 0.0) ? (1.0 / g) : 0.0;
}

void InverseGamma::sample(Eigen::VectorXd &preallocated_vec) const {
  preallocated_vec.noalias() =
      Eigen::VectorXd::NullaryExpr(preallocated_vec.size(), [this]() {
        double g = this->dist(this->rng);
        return (g > 0.0) ? (1.0 / g) : 0.0;
      });
}

void InverseGamma::set_parameters(double alpha, double beta) {
  dist = std::gamma_distribution<double>(alpha, 1.0 / beta);
}

void MultivariateNormal::sample(
    Eigen::Ref<Eigen::MatrixXd> preallocated_mat) const {
  Eigen::Index dim = mean.size();
  Eigen::Index n = preallocated_mat.cols();
  if (preallocated_mat.rows() != dim) {
    throw std::invalid_argument(
        "MultivariateNormal::sample(matrix): row count mismatch");
  }
  Eigen::VectorXd z;
  for (Eigen::Index j = 0; j < n; ++j) {
    z = Eigen::VectorXd::NullaryExpr(dim, [this]() { return this->dist(rng); });
    preallocated_mat.col(j) = mean + L * z;
  }
}