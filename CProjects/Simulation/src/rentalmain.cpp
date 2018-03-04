#include "ark.hpp"
#include "ask.hpp"
#include "crb.hpp"
#include "crt.hpp"
#include "Dist.hpp"
#include "Importance.hpp"
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
    cout << d.studenttrnd(mu, sigma, 10, 15) << endl;
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
    x = d.studenttrnd(mu, sigma, 10, 4);
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
    MatrixXd X = d.studenttrnd(mu, sigma, 10, 15);
    for (int i = 0; i < X.rows(); i++) {
      cout << indicatorFunction(a, b, X.row(i)) << " " << X.row(i) << endl;
    }
  }
}

void TrunctTests(){
	cout << "Truncated T PDF Tests" << endl;
    double inf = numeric_limits<double>::max();
	Dist dist;
	cout << dist.ttpdf(0,1,10 ,0,1,.5) << endl;
	cout << dist.ttpdf(0, inf, 10, 0, 1, .5) << endl;
	cout << dist.ttpdf(-inf, 0, 10, -10, 5, -3) << endl;
}

int main() {
  {
    double inf = numeric_limits<double>::max();
    string filepath = "/Users/dillonflannery-valadez/Google "
                      "Drive/CodeProjects/CProjects/Simulation/"
                      "rentaldata.csv";
    MatrixXd DATA = readCSV(filepath, 32, 6);
    VectorXd y = DATA.col(5);
    VectorXd r = DATA.col(2);
    VectorXd rDno = r.array() / DATA.col(1).array();
    VectorXd s = DATA.col(3);
    VectorXd d = DATA.col(4);
    VectorXd srInteraction = s.array() * rDno.array();
    VectorXd girlrInteraction = (1 - s.array()) * rDno.array();
    VectorXd sdInteraction = s.array() * d.array();
    VectorXd girldInteraction = (1 - s.array()) * d.array();
    VectorXd constant = MatrixXd::Ones(32, 1);
    MatrixXd X(32, 5);
    X << constant, srInteraction, girlrInteraction, sdInteraction,
        girldInteraction;
    VectorXd MaximumLikelihoodEstsBeta =
        (X.transpose() * X).inverse() * X.transpose() * y;
    VectorXd residuals = y - X * MaximumLikelihoodEstsBeta;
    double s2hat = (residuals.transpose() * residuals).value() / (X.rows());
    MatrixXd MaximumLikelihoodEstsSigma =
        s2hat * (X.transpose() * X).inverse();
    cout << "MLES" << endl;
    VectorXd MLES(X.cols() + 1);
    MLES << s2hat, MaximumLikelihoodEstsBeta;
    printvec(MLES);
    MatrixXd V(X.cols() + 1, X.cols() + 1);
    V.setZero();
    V.block(1, 1, X.cols(), X.cols()) = MaximumLikelihoodEstsSigma;
    V(0, 0) = (2 * pow(s2hat, 2)) / (X.rows());
    int J = V.cols();
    VectorXd b0 = MaximumLikelihoodEstsBeta;
    MatrixXd B0 = 1000 * MatrixXd::Identity(J - 1, J - 1);
    double a0 = 3;
    double d0 = 5;

    Dist dist;
    // Constraints
    VectorXd a(X.cols() + 1);
    VectorXd b(X.cols() + 1);
    MatrixXd I = MatrixXd::Identity(X.cols() + 1, X.cols() + 1);
    a << 0, -inf, 0, 0, -inf, -inf;
    b << inf, inf, inf, inf, 0, 0;
    MatrixXd Z = MatrixXd::Zero(6, 1);
    MatrixXd Iden = I;
    Iden.array().colwise() *= V.diagonal().array().pow(-.5);
    MatrixXd Test = Iden * V * Iden;

    int simulations = 100;
    int burnin = .1 * simulations;
	int repititions = 50;
	int batches = .1*repititions;

    Crb crb;
    cout << "Crb" << endl;
	crb.runSim(MLES, V, y, X, a, b, simulations, burnin, repititions, batches, b0,B0,a0,d0);

    cout << "Crb Student T" << endl;
    crb.runTsim(MLES, V, J+1, y, X, a, b, I, b0, B0, a0, d0, simulations, burnin, simulations, burnin); 

    Crt crt;
    cout << "Crt" << endl;
    crt.runSim(repititions, batches, a,b,MLES, V, y,X,simulations, burnin, b0,B0,a0,d0);

    /*cout << "Crt Student T" << endl;
    Sample = dist.mvtstudtrnd(a, b, I, MLES, V, J + 1, simulations, burnin)
                 .bottomRows(simulations - burnin);
    zStar = Sample.colwise().mean();
    Kernel = dist.gibbsKernel(a, b, MLES, V, Sample, zStar);
    betas = zStar.tail(J - 1);
    cout << crt.ml(betas, zStar(0), Kernel, y, X, b0, B0, a0, d0) << endl;
    cout << endl;

   Ask ask;
    cout << "Ask" << endl;
    MatrixXd adaptSample =
        ask.adaptiveSampler(a, b, MLES, V, .5, 15000, 5000, 500);
    VectorXd zask = adaptSample.colwise().mean();
    MatrixXd K = ask.gibbsKernel(a, b, MLES, V, adaptSample, zask);
    VectorXd betasask = zask.tail(J - 1);
    cout << ask.ml(betasask, zask(0), y, DATA, K, b0, B0, a0, d0) << endl;
    cout << "Ask Student T" << endl;
	VectorXd weight(J+1);
	weight.fill(.5);
	adaptSample = ask.adaptiveSamplerT(a,b,I,MLES,V,J+1,.5,simulations,burnin,burnin, weight);
    zask = adaptSample.colwise().mean();
    K = ask.gibbsKernel(a, b, MLES, V, adaptSample, zask);
    betasask = zask.tail(J - 1);
    cout << ask.ml(betasask, zask(0), y, DATA, K, b0, B0, a0, d0) << endl;
	cout << endl;

	

    Importance imp;
    cout << "Importance " << endl;
    cout << imp.importanceSampling(a, b, MLES, V, y, DATA, simulations, b0, B0,
                                   a0, d0)
         << endl;

    cout << "Importance Student T proposal" << endl;
    cout << imp.trunctprop(a, b, I, MLES, V, J, y, DATA, simulations, b0, B0,
                           a0, d0)
         << endl;
	cout << endl;

    Ark ark;
    cout << "Ark" << endl;
    MatrixXd arSamp = ark.arSample(a, b, MLES, V, simulations, 100000);
    VectorXd zark = arSamp.colwise().mean();
    MatrixXd arkKernel = dist.gibbsKernel(a, b, MLES, V, arSamp, zark);
    VectorXd bark = zark.tail(J - 1);
    cout << ark.ml(bark, zark(0), y, DATA, arkKernel, b0, B0, a0, d0) << endl;
	cout << endl;
	cout << "Ark student t" << endl;
    arSamp = ark.arSampleT(a, b, I, MLES, V, J+1, simulations, 100000);
    zark = arSamp.colwise().mean();
    arkKernel = dist.gibbsKernel(a, b, MLES, V, arSamp, zark);
    bark = zark.tail(J - 1);
    cout << ark.ml(bark, zark(0), y, DATA, arkKernel, b0, B0, a0, d0) << endl;
	cout << endl;*/

  }
  {
    // RobertMethodTests();
    // TrunctTests();
  }
}
