#include "Dist.hpp"
#include "Importance.hpp"
#include "LinRegGibbs.hpp"
#include "ThreeD.hpp"
#include "ark.hpp"
#include "ask.hpp"
#include "crb.hpp"
#include "crt.hpp"
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
    cout << d.mvtrunctrnd(mu, sigma, 10, 15) << endl;
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
    x = d.mvtrunctrnd(mu, sigma, 10, 4);
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
    MatrixXd X = d.mvtrunctrnd(mu, sigma, 10, 15);
    for (int i = 0; i < X.rows(); i++) {
      cout << indicatorFunction(a, b, X.row(i)) << " " << X.row(i) << endl;
    }
  }
}

void TrunctTests() {
  cout << "Truncated T PDF Tests" << endl;
  double inf = numeric_limits<double>::max();
  Dist dist;
  cout << dist.ttpdf(0, 1, 10, 0, 1, .5) << endl;
  cout << dist.ttpdf(0, inf, 10, 0, 1, .5) << endl;
  cout << dist.ttpdf(-inf, 0, 10, -10, 5, -3) << endl;
}

void replicateTests() {
  double inf = numeric_limits<double>::max();
  cout << "Replication" << endl;
  VectorXd a(3);
  VectorXd b(3);
  a << 0, 0, 0;
  b << inf, inf, inf;
  VectorXd mu(3);
  mu << 0, .5, 1;
  MatrixXd S(3, 3);
  S << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  Crt crt;
  Dist d;
  int N = 100;
  MatrixXd normC(N, 3);
  crt.runSim(1000, 100, a, b, mu, S, 11000, 1000);
  d.returnNormalizingConstants(a, b, mu, S, N, normC);
  d.runSim(1000, 100, a, b, mu, S, 11000);
}

int main() {
  {
    double inf = numeric_limits<double>::max();
    string filepath = "/Users/dillonflannery-valadez/Google "
                      "Drive/CodeProjects/CProjects/Simulation/"
                      "rentaldata.csv";
    Dist dist;
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
    VectorXd sy = (y.array() - y.mean()) / dist.standardDev(y);
    VectorXd srDno = (r.array() - r.mean()) / dist.standardDev(rDno);
    VectorXd ss = (s.array() - s.mean()) / dist.standardDev(s);
    VectorXd sd = (d.array() - d.mean()) / dist.standardDev(d);
    VectorXd ssrInteraction = ss.array() * srDno.array();
    VectorXd sgirlInteraction = (1 - ss.array()) * srDno.array();
    VectorXd ssdInteraction = ss.array() * sd.array();
    VectorXd sgirldInteraction = (1 - ss.array()) * sd.array();
    MatrixXd sX(32, 4);
    sX << ssrInteraction, sgirlInteraction, ssdInteraction, sgirldInteraction;
    X << constant, srInteraction, girlrInteraction, sdInteraction,
        girldInteraction;
    VectorXd MaximumLikelihoodEstsBeta =
        (X.transpose() * X).inverse() * X.transpose() * y;
    VectorXd smles = (sX.transpose() * sX).inverse() * sX.transpose() * sy;
    cout << "Standardized X mles" << endl;
    cout << smles << endl;
    VectorXd residuals = y - X * MaximumLikelihoodEstsBeta;
    VectorXd sres = sy - sX * smles;
    double ss2hat = (sres.transpose() * sres).value() / sX.rows();
    double s2hat = (residuals.transpose() * residuals).value() / (X.rows());
    MatrixXd MaximumLikelihoodEstsSigma = s2hat * (X.transpose() * X).inverse();
    MatrixXd mleSigma = ss2hat * (sX.transpose() * sX).inverse();
    cout << "MLES" << endl;
    VectorXd MLES(X.cols() + 1);
    VectorXd sMles(smles.size() + 1);
    sMles << ss2hat, smles;
    MLES << s2hat, MaximumLikelihoodEstsBeta;
    printvec(MLES);
    MatrixXd V(X.cols() + 1, X.cols() + 1);
    MatrixXd sV(sMles.size(), sMles.size());
    sV.setZero();
    V.setZero();
    V.block(1, 1, X.cols(), X.cols()) = MaximumLikelihoodEstsSigma;
    sV.block(1, 1, sX.cols(), sX.cols()) = mleSigma;
    sV(0, 0) = (2 * pow(ss2hat, 2)) / (sX.rows());
    V(0, 0) = (2 * pow(s2hat, 2)) / (X.rows());
    int J = V.cols();
    int sJ = sV.cols();
    cout << sV << endl;
    VectorXd b0 = MaximumLikelihoodEstsBeta;
    VectorXd sb0(sX.cols());
    sb0.setZero();
    MatrixXd B0 = 1000 * MatrixXd::Identity(J - 1, J - 1);
    MatrixXd sB0 = MatrixXd::Identity(sJ - 1, sJ - 1);
    double a0 = 3;
    double d0 = 5;
    // Constraints
    VectorXd a(X.cols() + 1);
    VectorXd b(X.cols() + 1);
    VectorXd sa(sMles.size());
    VectorXd sb(sMles.size());
    MatrixXd I = MatrixXd::Identity(X.cols() + 1, X.cols() + 1);
    MatrixXd sI = MatrixXd::Identity(sX.cols()+1, sX.cols()+1);
    a << 0, -inf, 0, 0, -inf, -inf;
    b << inf, inf, inf, inf, 0, 0;

    sa << 0, 0, 0, -inf, -inf;
    sb << inf, inf, inf, 0, 0;
    MatrixXd Z = MatrixXd::Zero(6, 1);
    MatrixXd Iden = I;
    Iden.array().colwise() *= V.diagonal().array().pow(-.5);
    MatrixXd Test = Iden * V * Iden;

    int simulations = 11000;
    int burnin = .1 * simulations;
    int repititions = 500;
    int batches = .1 * repititions;

    cout << "Modified Gelfand Dey" << endl;
    LinRegGibbs lrg;
    lrg.runSimModified(repititions, batches, a, b, MLES, V, y, X, b0,
                       B0, a0, d0, simulations, burnin);
    cout << "Modified Gelfand Dey T" << endl;
    lrg.runTsimModified(repititions, batches, a, b, I, J + 1, MLES, V, y, X, b0,
                        B0, a0, d0, simulations, burnin);
    Crb crb;
    cout << "Crb" << endl;
    crb.runSim(MLES, V, y, X, a, b, simulations, burnin, repititions, batches,
               b0, B0, a0, d0);

    cout << "Crb Student T" << endl;
    crb.runTsim(MLES, V, J + 1, y, X, a, b, I, b0, B0, a0, d0, simulations,
                burnin, repititions, batches);

    Crt crt;
    cout << "Crt" << endl;
    crt.runSim(repititions, batches, a, b, MLES, V, y, X, simulations,
               burnin, b0, B0, a0, d0);

    cout << "Crt Student T" << endl;
    crt.runTsim(repititions, batches, a, b, I, J + 1, MLES, V, y, X,
                simulations, burnin, b0, B0, a0, d0);

    Ask ask;
    cout << "Ask" << endl;
    ask.runSim(repititions, batches, a, b, MLES, V, y, X, simulations, burnin,
               burnin, b0, B0, a0, d0);
    cout << "Ask Student T" << endl;
    VectorXd weight(J + 1);
    weight.fill(.5);
    ask.runTsim(repititions, batches, a, b, I, J + 1, MLES, V, y, X,
                simulations, burnin, burnin, .5, b0, B0, a0, d0, weight);

    Importance imp;
    cout << "Importance " << endl;
    imp.runSim(repititions, batches, MLES, V, y, X, a, b, simulations, burnin,
               b0, B0, a0, d0);
    cout << "Importance Student T proposal" << endl;
    imp.runTsim(repititions, batches, MLES, V, y, X, a, b, I, J + 1,
                simulations, b0, B0, a0, d0);

    Ark ark;
    cout << "Ark" << endl;
    ark.runSim(repititions, batches, MLES, V, y, X, a, b, simulations, 100000,
               b0, B0, a0, d0);
    cout << "Ark student t" << endl;
    ark.runTsim(repititions, batches, a, b, I, J + 1, MLES, V, y, X,
                simulations, 100000, b0,B0, a0, d0);
  }
  {
    // RobertMethodTests();
    // TrunctTests();
    //	replicateTests();
  }
}
