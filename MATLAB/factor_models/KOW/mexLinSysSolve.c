#include "mex.h"
#include <math.h>
#include <matrix.h>

void extractDiag(int Cols, double d[Cols], double *M) {
  for (int i = 0; i < Cols; i++) {
    for (int j = 0; j < Cols; j++) {
      if (i == j) {
        d[i] = M[j + i * Cols];
      }
    }
  }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  if (nrhs < 2 || nrhs > 2) {
    mexErrMsgTxt("Wrong number of function inputs. Two required.\n");
  }
  int RowsLowerC, ColsLowerC;
  double *x, *L, *Y, diag[ColsLowerC], Z[ColsLowerC], sum;
  RowsLowerC = mxGetM(prhs[0]);
  ColsLowerC = mxGetN(prhs[0]);
  x = mxGetPr(prhs[1]);
  L = mxGetPr(prhs[0]);
  extractDiag(ColsLowerC, diag, L);
  plhs[0] = mxCreateDoubleMatrix(ColsLowerC, 1, mxREAL);
  Y = mxGetPr(plhs[0]);
  /* Forward Solve */
  for (int i = 0; i < ColsLowerC; i++) {
    sum = 0;
    if (i == 0) {
      Z[0] = x[0] / diag[0];
    } else {
      for (int j = 0; j < i; j++) {
        sum += L[i + j * ColsLowerC] * Z[j];
      }
      Z[i] = (x[i] - sum) / diag[i];
    }
  }
  /* Backward solve */
  for(int i = ColsLowerC-1; i >= 0; i--){
	sum = 0;
    if(i == ColsLowerC-1){
	  Y[i] = Z[i]/diag[i];
	}else{
      for (int j = ColsLowerC-1; j > i; j--) {
        sum += L[i*ColsLowerC +j] * Y[j];
      }
	    Y[i] = (Z[i] - sum) / diag[i];
	}
  }  
}
