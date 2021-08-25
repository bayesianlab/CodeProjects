// C Coding Challenge 

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "c_challenge.h"


double rad_to_degrees(double radians){
	return (180.0/M_PI)*radians;
}


double sine(double angle, int tay_max){
	double tay_sum = 0;
	for(int i=0; i <= tay_max; ++i){
		tay_sum= tay_sum + ( pow(-1, i)*pow(angle, (2*i) + 1)) / tgamma(((2*i)+1) + 1);
	}
	return tay_sum;
}

double cosine(double angle, int tay_max){
	double tay_sum = 0;
	for(int i=0; i <= tay_max; ++i){
		tay_sum= tay_sum + pow(-1, i)*pow(angle, 2*i)/tgamma( (2*i) + 1 );
	}
	return tay_sum;
}


double tangent(double angle, int tay_max){
	return sine(angle, tay_max)/cosine(angle, tay_max);
}

double cosecant(double angle, int tay_max){
	return 1./sine(angle, tay_max);
}

double secant(double angle, int tay_max){
	return 1./cosine(angle, tay_max);
}

double cotangent(double angle, int tay_max){
	return 1./tangent(angle, tay_max);
}