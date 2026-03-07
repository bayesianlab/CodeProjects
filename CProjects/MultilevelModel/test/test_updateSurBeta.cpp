#include <Eigen/Dense>
#include <cmath>
#include <gtest/gtest.h>
#include <vector>

#include "BayesianUpdates.hpp"
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "SURTestData.hpp"

using namespace Eigen;
using namespace std;

class UpdateSurBetaTest : public ::testing::Test {
protected:
  void SetUp() override {
    // Set up test data
    K = 2;   // number of equations
    T = 500; // number of time periods
    p = 3;   // number of parameters per equation

    // Create positive definite prior covariance B0
    B0 = 10 * MatrixXd::Identity(K * p, K * p);

    // Prior mean (as row vector)
    b0 = RowVectorXd::Zero(p * K);
  }

  int K, T, p;
  MatrixXd yt, Xt, Sigma, B0, epsilon;
  RowVectorXd b0;
  RowVectorXd btrue;
  SurBetaUpdater updater;
};

TEST_F(UpdateSurBetaTest, GenData) {
  int sims = 1000;
  int reps = 100;
  SURTestData testData = SURTestData(K, T, p);
  btrue = testData.predictors;
  int *coverage = new int[btrue.size()]();
  for (int j = 0; j < reps; ++j) {
    std::cout << "Repetition " << j + 1 << " of " << reps << std::endl;
    SURTestData testData = SURTestData(K, T, p);
    testData.generate();
    yt = testData.yt;
    Xt = testData.Xt;
    Sigma = testData.Sigma;
    std::vector<RowVectorXd> betaPost;
    Eigen::MatrixXd surX = surForm(Xt, K);
    for (int i = 0; i < sims; ++i) {
      updater.updateSurBeta(yt, surX, Sigma, b0, B0);
      betaPost.push_back(updater.bnew.transpose());
    }
    RowVectorXd betaPostMean = mean(betaPost);
    for (int k = 0; k < betaPostMean.size(); ++k) {
      double lower = betaPostMean(k) - 1.96 * sqrt(updater.B(k, k) / sims);
      double upper = betaPostMean(k) + 1.96 * sqrt(updater.B(k, k) / sims);
      if (btrue(k) >= lower && btrue(k) <= upper) {
        coverage[k]++;
      }
    }
  }
  for (int n = 0; n < btrue.size(); ++n) {
    EXPECT_NEAR(coverage[n] / double(reps), 0.95, 0.05);
  }
}

// // Test 1: Basic functionality - check dimensions
// TEST_F(UpdateSurBetaTest, OutputDimensions) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   EXPECT_EQ(updater.B.rows(), p);
//   EXPECT_EQ(updater.B.cols(), p);
//   EXPECT_EQ(updater.bmean.size(), p);
//   EXPECT_EQ(updater.bnew.size(), p);
// }

// // Test 2: Posterior covariance B is symmetric
// TEST_F(UpdateSurBetaTest, BMatrixIsSymmetric) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   MatrixXd diff = updater.B - updater.B.transpose();
//   double maxDiff = diff.cwiseAbs().maxCoeff();
//   EXPECT_NEAR(maxDiff, 0.0, 1e-10);
// }

// // Test 3: Posterior covariance B is positive definite
// TEST_F(UpdateSurBetaTest, BMatrixIsPositiveDefinite) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   SelfAdjointEigenSolver<MatrixXd> eigen_solver(updater.B);
//   VectorXd eigenvalues = eigen_solver.eigenvalues();

//   for (int i = 0; i < eigenvalues.size(); ++i) {
//     EXPECT_GT(eigenvalues(i), 0.0) << "Eigenvalue " << i << " is not
//     positive";
//   }
// }

// // Test 4: Posterior mean is within reasonable bounds
// TEST_F(UpdateSurBetaTest, PosteriorMeanIsFinite) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   for (int i = 0; i < updater.bmean.size(); ++i) {
//     EXPECT_TRUE(isfinite(updater.bmean(i)))
//         << "posterior mean element " << i << " is not finite";
//   }
// }

// // Test 5: Posterior draw is finite
// TEST_F(UpdateSurBetaTest, PosteriorDrawIsFinite) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   for (int i = 0; i < updater.bnew.size(); ++i) {
//     EXPECT_TRUE(isfinite(updater.bnew(i)))
//         << "posterior draw element " << i << " is not finite";
//   }
// }

// // Test 6: Multiple calls produce different draws (stochastic)
// TEST_F(UpdateSurBetaTest, DifferentDrawsAreProduced) {
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);
//   RowVectorXd draw1 = updater.bnew;

//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);
//   RowVectorXd draw2 = updater.bnew;

//   // Draws should be different (with very high probability)
//   double diffNorm = (draw1 - draw2).norm();
//   EXPECT_GT(diffNorm, 1e-10);
// }

// // Test 7: Check that B0 affects posterior through precision
// TEST_F(UpdateSurBetaTest, PriorAffectsPosterior) {
//   // Test that different priors produce different results
//   updater.updateSurBeta(yt, Xt, Sigma, b0, B0);

//   // Just verify that the result is valid
//   EXPECT_TRUE(isfinite(updater.bmean(0)));
//   EXPECT_EQ(updater.B.rows(), p);
// }

// // Test 8: Edge case - single time period
// TEST_F(UpdateSurBetaTest, SingleTimePeriod) {
//   MatrixXd yt_single = yt.col(0);
//   MatrixXd Xt_single = Xt.block(0, 0, K, p);

//   updater.updateSurBeta(yt_single, Xt_single, Sigma, b0, B0);

//   EXPECT_EQ(updater.B.rows(), p);
//   EXPECT_EQ(updater.B.cols(), p);
//   EXPECT_TRUE(isfinite(updater.bmean(0)));
// }

// // Test 9: Posterior mean is influenced by data
// TEST_F(UpdateSurBetaTest, DataInfluencesPosteriorMean) {
//   RowVectorXd b0_first = RowVectorXd::Zero(p);
//   updater.updateSurBeta(yt, Xt, Sigma, b0_first, B0);
//   RowVectorXd bmean_first = updater.bmean;

//   // Use different prior mean
//   RowVectorXd b0_second = RowVectorXd::Ones(p) * 5.0;
//   updater.updateSurBeta(yt, Xt, Sigma, b0_second, B0);
//   RowVectorXd bmean_second = updater.bmean;

//   // Posterior means should be different but not equal to prior means
//   double diff = (bmean_first - bmean_second).norm();
//   EXPECT_GT(diff, 1e-10);
// }

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
