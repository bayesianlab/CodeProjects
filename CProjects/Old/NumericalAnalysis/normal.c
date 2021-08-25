#include <stdio.h> 
#include <limits.h>
#include <float.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

double rnorm();

double runif(int, int);

int main(){
	time_t t;
	srand((unsigned) time(&t));
	printf("Running normal.c\n");
	printf("Normal Random %f\n", rnorm(0.0,1.0));
	return 0;
} 

double rnorm(double mu, double sigma){
	const double two_pi = 2.0*3.14159265358979323846;
	double x1, x2, u1, u2;
	u1 = runif(0,1);
	u2 = runif(0,1);
	printf("u1 %f u2 %f\n", u1, u2);
	x1 = sqrt(-2*log(u1)) * sin(two_pi * u2);
	x2 = sqrt(-2*log(u1)) * cos(two_pi * u2);
	return mu + sigma*x2;
} 

double runif(int min, int max){
	return rand() * (max - min) / ((double)RAND_MAX + min);
} 
