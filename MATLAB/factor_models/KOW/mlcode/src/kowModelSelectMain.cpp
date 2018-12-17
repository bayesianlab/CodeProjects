#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;
using namespace Eigen::internal;

int main(){
  
   MatrixXd bm = MatrixXd::Zero(3,3);

   bm.diagonal(1).setConstant(1);
   cout << bm << endl; 
	cout << "Main Function End." << endl;

}
