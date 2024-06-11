#include "Distributions.hpp"
#include "EigenTools.hpp"
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

void TriangularSolver(const MatrixXd &AAT, int cols) {
  MatrixXd B= MatrixXd::Zero(AAT.rows(), cols);
  for (int j = 0; j < cols; ++j) {
    RowVectorXd r1 = B.row(j).segment(0, j);
    for (int i = j; i < AAT.rows(); ++i) {
      RowVectorXd r2 = B.row(i).segment(0, j);
      double inner_prod = (r1.array() * r2.array()).sum();
      if (i == j) {
        B(i, j) = sqrt(AAT(i, j) - inner_prod);
      } else {
        B(i, j) = (AAT(i, j) - inner_prod)/B(j,j);
      }
    }
  }
  cout << B << endl; 
}

int main() {
  cout << "scratch" << endl;
  MatrixXd A = MatrixXd::Ones(10, 3);
  A.col(1) = .5 * A.col(0);
  A.col(2) = .5 * A.col(1);
  for (int i = 0; i < A.rows(); ++i) {
    for (int j = 0; j < A.cols(); ++j) {
      if (j > i) {
        A(i, j) = 0;
      }
    }
  }
  cout << A << endl;

  MatrixXd AAT = A * A.transpose();
  MatrixXd M = A * A.transpose();
  cout << M << endl;
  TriangularSolver(AAT, 3);

  MatrixXd H = normrnd(0, 1, 10, 2);
  for (int i = 0; i < H.rows(); ++i) {
    for (int j = 0; j < H.cols(); ++j) {
      if (j > i) {
        H(i, j) = 0;
      }
      if(i==j){
        H(i,j) = H(i,j)*H(i,j);
      }
    }
  }
  MatrixXd HHT = H * H.transpose();

  cout << H << endl;
  TriangularSolver(HHT, 2);
}