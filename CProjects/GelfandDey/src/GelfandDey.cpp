#include <iostream>
#include <Eigen/Dense>
#include <cstdint>
#include <ctime>
#include <limits>
#include <math.h>
#include "Dist.hpp"

using namespace Eigen;
using namespace std;

template<typename D>
void marginalLikeGD(const EigenBase<D> &sample) {
	cout << sample << endl;
}

