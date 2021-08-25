#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>
#include "read_csv_to_eigen.hpp"
using namespace std;
using namespace Eigen;

int main() {
  MatrixXd X(200, 8);
  cout << readCSV("mroz.csv", 200, 22) << endl; 
  return 0;
}
