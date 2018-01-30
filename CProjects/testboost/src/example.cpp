#include <Eigen/Dense>
#include <iostream>
using namespace std;
using namespace Eigen;
int main(int argc, char *argv[]) {
  if (argv != NULL) {
    double x = atof(argv[1]);
	Matrix<float, 2, 1> X;
	X(0) = 1.0;
	X(1) = x;
	cout << X << endl;
  } else {
    return 1;
  }
}
