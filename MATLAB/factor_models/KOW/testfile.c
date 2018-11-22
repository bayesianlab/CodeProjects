#include "mex.h"
#include <math.h>
#include <matrix.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  int Rows0 = mxGetM(prhs[0]);
  int Cols1 = mxGetN(prhs[1]);
  mxArray *output[1];
  mxArray *input[2];
  input[0] = (mxArray *)prhs[0];
  input[1] = (mxArray *)prhs[1];
  mexCallMATLAB(1, output, 2, input, "mtimes");
  plhs[0] = output[0];
  return;
}


