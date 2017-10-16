#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/uniform_01.hpp>
#include <limits>
#include <math.h>
#include <ctime>
#include <assert.h>
#include <cstdint>
#include "Dist.hpp"
#include "ask.hpp"

using namespace Eigen;
using namespace std;


Ask::Ask(){
	cout << "\n\n\tBegin ASK" << endl;
}

