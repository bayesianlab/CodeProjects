#include <math.h>
#include "mex.h"
double simpleFunc(double x[], double y[]){
	y[0] = x[0] * 100.;
}

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	double *x = mxGetPr(prhs[0]);
	double *y;
	simpleFunc(x, y);

}
