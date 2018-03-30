#include "Dist.hpp"
#include "LinRegGibbs.hpp"
#include "eigenshorts.hpp"
#include "read_csv_to_eigen.hpp"
#include "timeseries.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>
#include <random>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>

using namespace std;
using namespace Eigen;

int main() {
  cout << "VAR MAIN" << endl;
  Dist d;
  int N = 1000;
  int k = 2;
  MatrixXd Yt(N, k);
  double phi1 = 1.4;
  double phi2 = -.8;
  double phi3 = .9;
  double phi4 = -.3;
  Yt(0, 0) = -1;
  Yt(0, 1) = 5;
  for (int i = 1; i < N; i++) {
    Yt(i, 0) =
        1 + phi1 * Yt(i - 1, 0) + phi2 * Yt(i - 1, 1) + d.normrnd(0, .25);
    Yt(i, 1) =
        .3 + phi3 * Yt(i - 1, 0) + phi4 * Yt(i - 1, 1) + d.normrnd(0, .25);
  }
  std::ofstream file("yt.txt");
  file << Yt;
  file.close();
  TimeSeries ts;
  cout << ts.VAR(Yt, 1) << endl;
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
  return 1;
}
