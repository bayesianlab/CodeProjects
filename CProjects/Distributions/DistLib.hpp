#ifndef DISTLIB_HPP
#define DISTLIB_HPP

#include <Eigen/Dense>
#include <Eigen/src/Core/Matrix.h>
#include <memory>
#include <random>

class Normal {
public:
  Normal(std::mt19937 &_rng) : rng(_rng) {}

  Normal(double mu, double sigma, std::mt19937 &_rng)
      : dist(mu, sigma), rng(_rng) {}

  void set_parameters(double mu, double sigma);

  double sample() const;

  void sample(Eigen::VectorXd &vec);

  void sample(Eigen::MatrixXd &mat);

private:
  mutable std::normal_distribution<double> dist;

  std::mt19937 &rng;
};

class MultivariateNormal {
public:

  MultivariateNormal(const Eigen::VectorXd &mean, const Eigen::MatrixXd &cov,
                     std::mt19937 &_rng)
      : rng(_rng), mean(mean), L(cov.llt().matrixL()) {
    if (mean.size() != cov.rows() || mean.size() != cov.cols()) {
      throw std::invalid_argument(
          "MultivariateNormal: mean and covariance dimension mismatch");
    }
    // dist is constructed with (0,1) already; NormalUnivariate will use it
  }

  void sample(Eigen::Ref<Eigen::MatrixXd>) const;

private:
  std::mt19937 &rng;
  const Eigen::VectorXd mean;
  const Eigen::MatrixXd L;                       // lower Cholesky factor
  mutable std::normal_distribution<double> dist; // reused for efficiency
};

class InverseGamma {
public:
  InverseGamma(std::mt19937 &_rng) : rng(_rng), dist(3.0, 1.0/2.0) {}

  InverseGamma(double alpha, double beta, std::mt19937 &_rng)
      : rng(_rng), dist(alpha, 1.0 / beta) {}

  double sample() const;

  void set_parameters(double alpha, double beta);

  void sample(Eigen::VectorXd &preallocated_vec) const;

private:
  std::mt19937 &rng;
  mutable std::gamma_distribution<double> dist;
};



#endif
