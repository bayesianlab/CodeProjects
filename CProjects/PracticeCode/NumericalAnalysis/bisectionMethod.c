#include <stdio.h>
#include <math.h>

float polynomial(float x, float coefs[], int arrSize);

float bisection(float a, float b, float coefs[], int arrSize, int itsMax, float tol);

void run();

int main(){
	run();
	return 1;
}

void run(){
	int arrSz = 4;
	float tol = pow(10, -6);
	float coefs[arrSz];
	coefs[0] = 1.0;
	coefs[1] = -2.0;
	coefs[2] = -1.0;
	coefs[3] = 1.0;
	int itsMax = pow(10, 6);
	bisection(-2.0, 0.0, coefs, arrSz, itsMax, tol);
} 

float polynomial(float x, float coefs[], int arrSize){
	float y = coefs[arrSize - 1];
	arrSize = arrSize - 1;
	while(arrSize > 0){
		--arrSize;
		y = coefs[arrSize] + x * y;
	} 
	return y;
} 

float bisection(float a, float b, float coefs[], int arrSize, int itsMax, float tol){
	float fa;
	float fb;
	float fc;
	float error;
	int its = 0;
	fa = polynomial(a, coefs, arrSize);
	fb = polynomial(b, coefs, arrSize);
	printf("fa, fb, %f, %f\n", fa, fb);
	if(fa * fb > 0){
		printf("Error same sign.\n");
		return 0.0;
	} 
	while(its < itsMax){
		error = 0.5*(a + b);		
		fc = polynomial(error, coefs, arrSize);
		if(fabs(fc) < tol){
			printf("\nBisection Method Converged\n"  
					"Iterations: \t %d\n"
					"Root: \t %f\n", its, error);
			return error;
		} 
		if(fa*fc < 0){
			b = error;
			fb = fc;
		} 
		else{
			a = error;
			fa = fc;
		} 
		its++;
	}	
	return 0.0;
} 

