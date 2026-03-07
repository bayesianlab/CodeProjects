#include "Dist.hpp"
#include "Importance.hpp"
#include "LinRegGibbs.hpp"
#include "ark.hpp"
#include "ask.hpp"
#include "crb.hpp"
#include "crt.hpp"
#include <Eigen/Dense>
#include <ctime>
#include <fstream>
#include <iostream>
#include <limits>
#include <math.h>

using namespace std;
using namespace Eigen;

void pm(const Ref<MatrixXd> x){
	cout << x << endl;
}

int main() {
  cout << "fix dist" << endl;
  Dist d;
  VectorXd t(10000);
  for (int i = 0; i < 4; i++) {
    cout << d.igammarnd(3, 1./6, 10000).mean() << endl;
    d.igammarnd(3, 1./6, t);
    cout << t.mean() << endl;
    cout << endl;
	
	/* b / a - 1  mean (6 / 2)*/
  }
  cout << d.normrnd(9, 1, 1000).mean() << endl;
  cout << endl;
  cout << d.normrnd(1.3, 1, 10, 3) << endl;
  MatrixXd X = d.normrnd(0,1,3,3);
  cout << endl;
  pm(X.block(1,1, 2, 2));
  pm(X.col(0));
  return 0;
  
}
