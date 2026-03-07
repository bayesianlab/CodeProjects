#include <boost/python.hpp>
#include <Eigen/Dense>
using namespace Eigen;
char const* yay(){
	MatrixXd X(2,2);
	X.setZero();
	return "yay!";
	
}

BOOST_PYTHON_MODULE(libyay){
    using namespace boost::python;
	def("yay", yay);
}
