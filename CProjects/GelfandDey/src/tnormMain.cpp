#include "CreateSampleData.hpp"
#include "Dist.hpp"
#include "GelfandDey.cpp"
#include "LinRegGibbs.hpp"
#include <Eigen/Dense>
#include <iostream>

using namespace std;
using namespace Eigen;
int main() {
  double inf = numeric_limits<double>::max();
 
 
	Dist d;
	cout << d.truncNormalRnd(0, 1, 1.4, .014) << endl;
	
}
