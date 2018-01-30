#include <math.h>
#include "mex.h"
double simpleFunc(double x){
	return x * 100.;
}

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	double x = mxGetScalar(prhs[0]);
	plhs[0] = simpleFunc(x);

}
