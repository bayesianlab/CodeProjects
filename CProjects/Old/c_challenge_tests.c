// C Challenge Tests

// DO NOT CHANGE THESE TESTS!!! 

#include <math.h>
#include <stdio.h>
#include <assert.h>
#include "c_challenge.h"

#define SINE_TEST 0.70710678118
#define TANGENT_TEST 1.0
#define EPSILON 1e-4
#define TAY_MAX 40

int double_compare(double a, double b, double tol){
	if(fabs(a-b) < tol){
		return 1;
	}
	else{
		return 0; 
	}
}

// DO NOT CHANGE THIS FUNCTION !!
int test_function(double radian, double test_value, int tay_max, double eps, int test_number,
	double (*trig_function)(double, int)){
	double trig_val = trig_function(radian, tay_max);
	if( double_compare(trig_val, test_value, eps) == 1){
		printf("TEST %i PASSED\n", test_number);
		return 0;
	}
	else{
		printf("TEST FAILED\n");
		printf("\t expected:   %.8f\n", test_value);
		printf("\t returned:   %.8f\n", trig_val);
		printf("\t diff:       %.8f\n", fabs(test_value-trig_val));
		return 1;
	}
}

int main(){

	double test_array[17]= {0, M_PI/6., M_PI/4., M_PI/3., M_PI/2., 2*M_PI/3., 
		3*M_PI/4., 5*M_PI/6, M_PI, 7*M_PI/6., 5*M_PI/4., 4*M_PI/3, 3*M_PI/2., 5*M_PI/3.,
		7*M_PI/4., 11*M_PI/6, 2*M_PI};
	
	int n_fails = 0;
	printf("\nTests for sine\n");
	int j = 0;
	for(int i = 0; i<17; ++i){
		++j;
		n_fails +=test_function(test_array[i],  sin(test_array[i]), TAY_MAX, EPSILON, j, sine);
	}

	printf("\nTests for cosine\n");
	j = 0;
	for(int i = 0; i<17; ++i){
		++j;
		n_fails += test_function(test_array[i],  cos(test_array[i]), TAY_MAX, EPSILON, j, cosine);
	}

	printf("\nTests for tangent\n");
	for(int i = 0; i<17; ++i){			
		if( (i!=4) && (i!=12) ){
			n_fails += test_function(test_array[i],  tan(test_array[i]), TAY_MAX, EPSILON, i+1, tangent);
		}
	}

	printf("\nTests for cosecant\n");
	j = 0;
	for(int i = 0; i<17; ++i){			
		if( (i!=0) && (i!=8) && (i!=16)){
			++j;
			n_fails += test_function(test_array[i],  1./sin(test_array[i]), TAY_MAX, EPSILON, j, cosecant);
		}
	}

	printf("\nTests for secant\n");
	j = 0; 
	for(int i = 0; i<17; ++i){			
		if( (i!=4) && (i!=12) ){
			++j; 
			n_fails += test_function(test_array[i],  1./cos(test_array[i]), TAY_MAX, EPSILON, j, secant);
		}
		
	}

	printf("\nTests for cotangent\n");
	j = 0;
	for(int i = 0; i<17; ++i){			
		if( (i!=0) && (i!=8) && (i!=16) ){
			++j;
			n_fails += test_function(test_array[i],  1./tan(test_array[i]), TAY_MAX, EPSILON, j, cotangent);
		}
	}

	printf("\nTests Complete\n");
	printf("Number of failed tests: %d\n", n_fails);
	if(n_fails == 0){
		printf("You passed the test.\n");
	}
	else{
		printf("Your code is no good.\n");
	}
	return 0; 
}