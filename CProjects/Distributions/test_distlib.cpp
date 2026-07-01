
#include "DistLib.hpp"
#include "gtest/gtest.h"
#include <Eigen/Dense>
#include <Eigen/src/Core/Matrix.h>
#include <chrono>
#include <random>
#include <vector>

using namespace Eigen;
using namespace std;

class DistLibTest : public ::testing::Test {
protected:
  std::random_device rd;
  std::mt19937 rng;
  int reps;

  DistLibTest() : rd(), rng(rd()), reps(100) {}
};

TEST_F(DistLibTest, Normal) {

  Normal n(rng);

  Eigen::VectorXd v(1000);
  std::vector<double> means;
  double sample_mean = 0.;
  double sample_var = 0.0;
  double mean;
  auto start = std::chrono::high_resolution_clock::now();
  for (int i = 0; i < reps; ++i) {
    n.sample(v);
    mean = v.mean();
    sample_mean += mean;
    sample_var += (v.array() - mean).square().sum() / (v.size() - 1);
  }
  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double, std::milli> duration = end - start;
  sample_mean = sample_mean / reps;
  sample_var = sample_var / reps;
  EXPECT_NEAR(sample_mean, 0.0, .1);
  EXPECT_NEAR(sample_var, 1.0, .1);
  std::cout << "Good time = 213 ms" << std::endl;
  std::cout << duration.count() << " ms" << std::endl;
}

TEST_F(DistLibTest, InverseGamma) {
  InverseGamma g(rng);
  Eigen::VectorXd v(1000);
  std::vector<double> means;
  double sample_mean = 0.;
  double sample_var = 0.0;
  double mean;
  auto start = std::chrono::high_resolution_clock::now();
  for (int i = 0; i < reps; ++i) {
    g.sample(v);
    mean = v.mean();
    sample_mean += mean;
    sample_var += (v.array() - mean).square().sum() / (v.size() - 1);
  }
  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double, std::milli> duration = end - start;
  sample_mean = sample_mean / reps;
  sample_var = sample_var / reps;

  EXPECT_NEAR(sample_mean, 1.0, .1);
  EXPECT_NEAR(sample_var, 1.0, .1);
    std::cout << "Good time = 35 ms" << std::endl;

  std::cout << duration.count() << " ms" << std::endl;
}

TEST_F(DistLibTest, MultivariateNormal) {
  
  Eigen::Index N = 5;
  Eigen::MatrixXd S = Eigen::MatrixXd::Identity(N, N);
  Eigen::VectorXd m = Eigen::VectorXd::Ones(N);
  auto start = std::chrono::high_resolution_clock::now();
  MultivariateNormal mvn(m , S, rng);
  MatrixXd U(N, 1000);
  mvn.sample(U);
  auto end = std::chrono::high_resolution_clock::now();
  VectorXd sample_means = U.rowwise().mean();
  std::cout << sample_means  << std::endl;
  std::chrono::duration<double, std::milli> duration = end - start;
  std::cout << duration.count() << " ms" << std::endl;
}