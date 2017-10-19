#include <Eigen/Dense>
#include <boost/math/distributions/normal.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/math/distributions/bernoulli.hpp>
#include <limits>
#include <math.h>
#include <ctime>
#include <assert.h>
#include <cstdint>
#include <random>

#include "Dist.hpp"
#include "ark.hpp"

using namespace Eigen;
using namespace std;

Ark::Ark(){
	cout << "\n\n\tARK begin" << endl;
}
