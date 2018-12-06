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
  
   BandMatrix<double> bm(3,3,1,0);
   bm.setZero();
   bm.diagonal(1).setConstant(1);
   cout << bm.toDenseMatrix() << endl; 
	cout << "Main Function End." << endl;

}
