#include "Dist.hpp"
#include "LinRegGibbs.hpp"
#include "timeseries.hpp"
#include <Eigen/Dense>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>
#include <random>
#include <sstream>
#include <stdio.h>
#include <unsupported/Eigen/KroneckerProduct>

using namespace std;
using namespace Eigen;

void testVar() {
  Dist d(1);
  int N = 100;
  int k = 3;
  MatrixXd Yt(N, k);
  double phi1 = .3;
  double phi2 = -.3;
  double phi3 = .3;
  double phi4 = -.5;
  double phi5 = .5;
  double phi6 = -.5;
  double phi7 = -.2;
  double phi8 = -.2;
  double phi9 = .2;
  Yt(0, 0) = -1;
  Yt(0, 1) = 5;
  Yt(0, 2) = 3;
  for (int i = 1; i < N; i++) {
    Yt(i, 0) = -.5 + phi1 * Yt(i - 1, 0) + phi2 * Yt(i - 1, 1) +
               phi3 * Yt(i - 1, 2) + d.normrnd(0, 2);
    Yt(i, 1) = -.2 + phi4 * Yt(i - 1, 0) + phi5 * Yt(i - 1, 1) +
               phi6 * Yt(i - 1, 2) + d.normrnd(0, 2);
    Yt(i, 2) = .1 + phi7 * Yt(i - 1, 0) + phi8 * Yt(i - 1, 1) +
               phi9 * Yt(i - 1, 2) + d.normrnd(0, 2);
  }
  std::ofstream file("yt.txt");
  file << Yt;
  file.close();
  TimeSeries ts;
  cout << ts.VAR(Yt.leftCols(2), 1) << endl;
  cout << "Sigma Hat Sqd" << endl;
  cout << ts.calcSigmaHatSqd(Yt, 1) << endl;
  MatrixXd Zt(N, 1);
  for (int i = 1; i < N; i++) {
    Zt(i, 0) = 2 + .7 * Zt(i - 1, 0) + d.normrnd(0, 1);
  }
  cout << "BVAR" << endl;
  {
    Dist d(1);
    int N = 50;
    int k = 2;
    MatrixXd Yt(N, k);
    double phi1 = .8;
    double phi2 = -.8;
    double phi3 = .7;
    double phi4 = -.7;
    Yt(0, 0) = 5;
    Yt(0, 1) = -5;
    for (int i = 1; i < N; i++) {
      Yt(i, 0) =
          .5 + phi1 * Yt(i - 1, 0) + phi2 * Yt(i - 1, 1) + d.normrnd(0, 1);
      Yt(i, 1) =
         -.5 + phi3 * Yt(i - 1, 0) + phi4 * Yt(i - 1, 1) + +d.normrnd(0, 1 );
    }
    cout << ts.VAR(Yt, 2) << endl;
	cout << endl;
        ts.BvarMinnesota(Yt, 2, 1000, .2, .5, 1000, 100);
  }
}


void testMatricVariateNormal() {
  Dist d(1);
  MatrixXd A(2, 2);
  A << 1, .5, .5, 1;
  MatrixXd B = MatrixXd::Identity(2,2); 
  MatrixXd T = kroneckerProduct(B, A);
  cout << T << endl;
  MatrixXd X(2,2);
  X << -10, -10, 10, 10;
  cout << X << endl;
  cout << "Matrix variate normal" << endl;
  cout << d.MatricVariateRnd(X, A, B) << endl;
}

void testWishart() {
  Dist d;
  MatrixXd Sigma(3, 3);
  std::mt19937 rng(1);
  Sigma << 1, -.7, .49, -.7, 1, -.7, .49, -.7, 1;
  for (int j = 0; j < 10; j++) {
    int c = 0;
    for (int i = 0; i < 100; i++) {
      MatrixXd w = d.wishartrnd(Sigma, 10);
      if (w(0, 0) > 20) {
        c++;
      }
    }
    cout << c / 100.0 << endl;
  }
}












int main() {
  cout << "VAR MAIN" << endl;
  Dist d;
  testVar();
  return 1;
}
