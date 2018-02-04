#ifndef EIGENSHORTS
#define EIGENSHORTS
#include <Eigen/Dense>
#include <string>
using namespace Eigen;
void printhead(const VectorXd &y);
void printhead(const MatrixXd &X);
void printvec(const VectorXd &x);
void printmat(const MatrixXd &X);
void printval(double d);
void msg(string s);
#endif
