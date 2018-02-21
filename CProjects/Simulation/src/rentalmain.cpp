#include "Ask.hpp"
#include "Ark.hpp"
#include "Crb.hpp"
#include "Crt.hpp"
#include "Importance.hpp"
#include "Dist.hpp"
#include "ThreeD.hpp"
#include "eigenshorts.hpp"
#include "read_csv_to_eigen.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
using namespace std;
using namespace Eigen;

int indicatorFunction(const VectorXd &a, const VectorXd &b, const VectorXd &x) {
  for (int i = 0; i < a.size(); i++) {
    if (a(i) > x(i) || x(i) > b(i)) {
      return 0;
    }
  }
  return 1;
}

void RobertMethodTests() {
  {
    cout << "Roberts Method Tests" << endl;
    double inf = numeric_limits<double>::max();
    Dist d;

    for (int i = 0; i < 10; i++) {
      cout << d.truncNormalRnd(-inf - 10, 0, 10, .1) << endl;
    }
    for (int i = 0; i < 10; i++) {
      printval(d.truncNormalRnd(0, 10, -10, .01));
    }
    msg("region include 0");
    for (int i = 0; i < 10; i++) {
      printval(d.truncNormalRnd(-5, 5, 10, .01));
    }
    msg("One sided tests");
    msg("Right Truncation");
    for (int i = 0; i < 10; i++) {
      printval(d.truncNormalRnd(-inf, -10, 0, 1));
    }
    msg("Left Truncation");
    for (int i = 0; i < 10; i++) {
      printval(d.truncNormalRnd(10, 1e8, 0, .001));
    }
    msg("Two sided");
    printval(d.truncNormalRnd(0, 1, 1, 1));
  }
}

void MvtPdfTests() {
  {
    VectorXd mu(3);
    mu << 0, 0, 0;
    MatrixXd sigma = MatrixXd::Identity(3, 3);
    sigma(1, 0) = .5;
    sigma(2, 0) = .25;
    sigma(0, 1) = .5;
    sigma(0, 2) = .25;
    sigma(1, 2) = .5;
    sigma(2, 1) = .5;
    VectorXd x(3);
    x << 1, 1.1, .8;
    cout << sigma << endl;
    Dist d;
    cout << d.mvtrnd(mu, sigma, 10, 15) << endl;
    cout << "mvtpdf" << endl;
    cout << d.mvtpdf(x, mu, sigma, 10) << endl;
  }
  {
    Dist d;
    VectorXd mu(3);
    mu << 0, 0, 0;
    MatrixXd sigma = MatrixXd::Identity(3, 3);
    sigma(1, 0) = .5;
    sigma(2, 0) = .25;
    sigma(0, 1) = .5;
    sigma(0, 2) = .25;
    sigma(1, 2) = .5;
    sigma(2, 1) = .5;
    MatrixXd x(4, 3);
    x = d.mvtrnd(mu, sigma, 10, 4);
    cout << "x" << endl;
    cout << x << endl;
    cout << "pdf(x)" << endl;
    cout << d.mvtpdf(x, mu, sigma, 10) << endl;
  }
  {
    double inf = numeric_limits<double>::max();
    VectorXd mu(3);
    mu << 0, 0, 0;
    MatrixXd sigma = MatrixXd::Identity(3, 3);
    sigma(1, 0) = .5;
    sigma(2, 0) = .25;
    sigma(0, 1) = .5;
    sigma(0, 2) = .25;
    sigma(1, 2) = .5;
    sigma(2, 1) = .5;
    Dist d;
    VectorXd a(3);
    VectorXd b(3);
    a << 0, 0, 0;
    b << inf, inf, inf;
    MatrixXd X = d.mvtrnd(mu, sigma, 10, 15);
    for (int i = 0; i < X.rows(); i++) {
      cout << indicatorFunction(a, b, X.row(i)) << " " << X.row(i) << endl;
    }
  }
}

int main() {
  {
    double inf = numeric_limits<double>::max();
    string filepath = "/Users/dillonflannery-valadez/Google "
                      "Drive/CodeProjects/CProjects/Simulation/"
                      "rentaldata.csv";
    MatrixXd X = readCSV(filepath, 32, 6);
    VectorXd y = X.col(5);
    VectorXd r = X.col(2);
    VectorXd rDno = r.array() / X.col(1).array();
    VectorXd s = X.col(3);
    VectorXd d = X.col(4);
    VectorXd srInteraction = s.array() * rDno.array();
    VectorXd girlrInteraction = (1 - s.array()) * rDno.array();
    VectorXd sdInteraction = s.array() * d.array();
    VectorXd girldInteraction = (1 - s.array()) * d.array();
    VectorXd constant = MatrixXd::Ones(32, 1);
    MatrixXd DATA(32, 5);
    DATA << constant, srInteraction, girlrInteraction, sdInteraction,
        girldInteraction;
    VectorXd MaximumLikelihoodEstsBeta =
        (DATA.transpose() * DATA).inverse() * DATA.transpose() * y;
    VectorXd residuals = y - DATA * MaximumLikelihoodEstsBeta;
    double s2hat = (residuals.transpose() * residuals).value() / (DATA.rows());
    MatrixXd MaximumLikelihoodEstsSigma =
        s2hat * (DATA.transpose() * DATA).inverse();
    cout << "MLES" << endl;
    VectorXd MLES(DATA.cols() + 1);
    MLES << s2hat, MaximumLikelihoodEstsBeta;
    printvec(MLES);
    MatrixXd V(DATA.cols() + 1, DATA.cols() + 1);
    V.setZero();
    V.block(1, 1, DATA.cols(), DATA.cols()) = MaximumLikelihoodEstsSigma;
    V(0, 0) = (2 * pow(s2hat, 2)) / (DATA.rows());
    int J = V.cols();
    MatrixXd b0 = MaximumLikelihoodEstsBeta;
    MatrixXd B0 = 100*MatrixXd::Identity(J - 1, J - 1);
    double a0 = 6;
    double d0 = 12;

    Dist dist;
    // Constraints
    VectorXd a(DATA.cols() + 1);
    VectorXd b(DATA.cols() + 1);
    MatrixXd I = MatrixXd::Identity(DATA.cols() + 1, DATA.cols() + 1);
    a << 0, -inf, 0, 0, -inf, -inf;
    b << inf, inf, inf, inf, 0, 0;
    MatrixXd Z = MatrixXd::Zero(6, 1);
    MatrixXd Iden = I;
    Iden.array().colwise() *= V.diagonal().array().pow(-.5);
    MatrixXd Test = Iden * V * Iden;
    MatrixXd Sample = dist.geweke91(a, b, I, MLES, V, 1500, 50);

    Crb crb;
    cout << "Crb" << endl;
    MatrixXd fzandz = crb.chibRao(a, b, MLES, V, 110000, 10000, 110000, 10000, 1);
	cout << fzandz << endl;
    VectorXd fz = fzandz.col(0);
    VectorXd z = fzandz.col(1);
    VectorXd betasCrb = z.tail(J - 1);
    cout << crb.ml(fz, betasCrb, z(0), y, DATA, b0, B0, a0, d0) << endl;
    cout << endl;

 /*   Crt crt;
    Sample = dist.tmultnorm(a, b, MLES, V, 150000).leftCols(J).bottomRows(100000);
    VectorXd zStar = Sample.colwise().mean();
    MatrixXd Kernel = dist.gibbsKernel(a, b, MLES, V, Sample, zStar);
    VectorXd betas = zStar.tail(J - 1);
    cout << "Crt" << endl;
    cout << crt.ml(betas, zStar(0), Kernel, y, DATA, b0, B0, a0, d0) << endl;
    cout << endl;

    Ask ask;
    cout << "Ask" << endl;
    MatrixXd adaptSample =
        ask.adaptiveSampler(a, b, MLES, V, .5, 150000, 50000, 5000);
    VectorXd zask = adaptSample.colwise().mean();
    MatrixXd K = ask.gibbsKernel(a, b, MLES, V, adaptSample, zask);
    VectorXd betasask = zask.tail(J - 1);
    cout << ask.ml(betasask, zask(0), y, DATA, K, b0, B0, a0, d0) << endl;

    Importance imp;
	cout << "Importance " << endl;
	
    cout << imp.importanceSampling(a, b, MLES, V, y, DATA, 150000, 50000, b0, B0,
                                   a0, d0)
         << endl;
	cout << imp.mlGeweke91(a, b, I, MLES, V, y, DATA, 150000, 50000, b0, B0,
                                   a0, d0) << endl;
	
	Ark ark;
	cout << "ark" << endl;
	MatrixXd arSamp = ark.arSample(a, b, MLES, V, 150000, 50000);
    VectorXd zark = arSamp.colwise().mean();
    MatrixXd arkKernel = dist.gibbsKernel(a, b, MLES, V, arSamp, zark);
    VectorXd bark = zStar.tail(J-1);
    cout<<  ark.ml(bark, zark(0), y, DATA, arkKernel, b0, B0, a0, d0) << endl;
	*/

  }
  {
    // RobertMethodTests();
  }
}
