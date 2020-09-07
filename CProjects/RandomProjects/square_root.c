#include <stdio.h> 
#include <math.h>
#include <stdlib.h> 
#include "square_root.h"  


double sroot(double x, double hi, double low,  double tol){
	double g = .5* ( hi + low );
	double val = g*g; 
	if( fabs(val - x ) < tol  ){
		return hi;  
	}else{
		if(val < x){
			sroot(x, hi, g, tol); 	
		}else{
			sroot(x, g, low, tol); 	
		}

	}
}



int main(int argc, char *argv[]) {
	double low =0; 
	char *p; 
	double x = strtod(argv[1], &p); 
	double hi = .5*x; 
	double tol = .00001; 
	double answer = sroot(x, hi, low, tol); 
	printf("%.5f \n", answer); 
	return 0; 
}
