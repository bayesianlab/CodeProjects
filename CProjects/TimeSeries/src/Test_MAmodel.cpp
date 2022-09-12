#include <stdio.h>

#include <Eigen/Dense>

#include "ARMA.hpp"
#include "GenerateAutoRegressiveData.hpp"
#include "MultilevelModelFunctions.hpp"

using namespace std;
using namespace Eigen;

int main() {
  MovingAverageModel ma;
  int p = 3;
  RowVectorXd thetas(p);
  thetas << .5, .5, .5;
  int T = 50;
  ma.genData(p, thetas, T);
  ma.runModel(100, 20);
  cout << "True values " << thetas << endl;
  cout << ma.thetas << endl;
}