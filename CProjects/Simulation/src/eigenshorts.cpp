#include <Eigen/Dense>
#include <iostream>
using namespace Eigen;
using namespace std;
void printhead(const VectorXd &y) {
  cout << "y's 5 first entries:" << endl;
  cout << y.head(5) << endl;
  cout << endl;
}

void printhead(const MatrixXd &X) {
  cout << "X first 5 rows:" << endl;
  cout << X.topRows(5) << endl;
  cout << endl;
}

void printvec(const Ref<const VectorXd> &x) {
  cout << x << endl;
  cout << endl;
}

void printmat(const MatrixXd &X){
	cout << X << endl;
	cout << endl;
}

void printval(double d){
	cout << d << endl;
}

void msg(string s){
	cout << s << endl;
}

