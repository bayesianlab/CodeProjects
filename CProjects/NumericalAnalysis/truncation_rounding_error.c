#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int differentiationError();

void displayArray();

double roundDouble();

double truncDouble();

void writeDoubleToFile();

int main(){
	int nSims = 30;
	int someArray[10];
	double x = .5;
	double pi = 3.14159;
	double pipi[2][2];
	pipi[0][0] = pi;
	pipi[0][1] = pi + 1;
	pipi[1][0] = pi;
	pipi[1][1] = pi + 1;
	differentiationError(0.5, someArray, 8.0,  nSims);
//
//	writeDoubleToFile(2,2,pipi);
	return 0;
} 

int differentiationError(double point, int someArray[], double h,  int nSims){
	int iter;
	int cols = 4;
	double approx = 0.0;
	double roundError = 0.0;
	double tStor = 0.0;
	double truth;
	double totErr;
	truth = cos(point);
	double roundTrunk[nSims][cols];
	for(iter=0;iter<nSims; ++iter){
		h = .5 * h;
		approx = ( sin(point + h) - sin(point) ) / h;
		roundError = truth - roundDouble(approx, 2);
		tStor = truth - truncDouble(approx, 2);
		totErr = log10(roundError + tStor);
		if(roundError < 0){
			roundError= roundError*-1.0;
		}
		if(tStor < 0){
			tStor = tStor * -1.0;
		}
		roundError = -log10(roundError);
		tStor = -log10(tStor);
	    roundTrunk[iter][0] = roundError;
		roundTrunk[iter][1] = tStor;
		roundTrunk[iter][2] = totErr; 
		roundTrunk[iter][3] = log10(h);
	} 
	writeDoubleToFile(nSims, cols, roundTrunk);
	return 0;
} 

double roundDouble(double x, long decimalPlaces){
	long decimals = pow(10,decimalPlaces);
	return round(x * decimals) / decimals;
}

double truncDouble(double x, long decimalPlaces){
	long decimals = pow(10,decimalPlaces);
	return trunc(x * decimals) / decimals;} 

void displayArray(double x[], int size){
	int i;
	printf("Double Array\n");
	for(i=0;i<size;i++){
		printf("%f\n", x[i]);
	} 
} 

void writeDoubleToFile(int rows, int cols, double someArray[][cols]){
	FILE *fp;
	fp = fopen("results.dat", "w");
	if(fp == NULL){
		printf("Couldn't open file.");
		exit(1);
	} 
	for(int r =0; r < rows; r++){
		for(int c =0; c < cols; c++){
			fprintf(fp, "%f    ", someArray[r][c]);
		}
	   fprintf(fp, "\n");	
	}
   fclose(fp);	
} 

