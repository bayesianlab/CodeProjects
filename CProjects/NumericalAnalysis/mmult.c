#include <stdio.h>
#include <time.h>
#include <math.h>
#include "mmult.h"

void mmult(int row1, int col1, double m1[][col1], int row2, int col2, double m2[][col2], 
		double result[row1][col2]){
	int currentSelection;
	int i;
	int j;
	double entryij;
	if(col1 != row2){
		printf("Error, dimensions do not agree, %d != %d", col1, row2);
	} 	
	for(currentSelection=0; currentSelection < row1; currentSelection++){
		for(i=0;i<col2;i++){
			entryij = 0; 
			for(j=0; j<row2; j++){
 				entryij = entryij + m1[currentSelection][j] * m2[j][i];
			}
			result[currentSelection][i] = entryij;
		} 
	} 
} 

double determinant2x2(int row, double matrix[row][row]){
	return (matrix[0][0] * matrix[1][1])-(matrix[1][0] * matrix[0][1]);
} 

void fillCofactor(int row, double matrix[row][row], double tmpMatrix[row-1][row-1], 
		int strikeout){
	int tempRowIndex = 0;
	for(int i = 1; i < row; i++){
		int tempColIndex = 0;
		for(int j =0; j < row; j++){
			if(j != strikeout){
				tmpMatrix[tempRowIndex][tempColIndex] = matrix[i][j];
				tempColIndex ++;
			} 
		} 
		tempRowIndex ++;
	} 
} 

double determinant(int row, double matrix[row][row] ){
	if( row == 2){
		return determinant2x2( row, matrix);
	}
	else{	
		double det = 0;
		for(int i=0; i<row;i++){
			double temp = matrix[0][i];
			double reducedMatrix[row-1][row-1];
			fillCofactor(row, matrix, reducedMatrix, i);
			det = det + pow(-1, i) * temp * determinant(row-1, reducedMatrix);
		}
		return det;
	}
} 

void transpose(int row1, int col1, double m1[][col1],
	   double m2[col1][row1]){
	for(int j = 0; j < col1; j++){
		for(int i =0; i < row1; i++){
			m2[j][i] = m1[i][j];
		} 
	} 
} 

void lin_reg(int rowY, double y[rowY], int rowX, int colX, double x[][rowX]){
	printf("\nnull\n");
} 

void printf2D(int nrow, int ncol, double twoDarr[nrow][ncol]){
	printf("\n");
	for(int i = 0; i < nrow; i++){
		for(int j = 0; j < ncol; j++){
			printf("%.2f ", twoDarr[i][j]);
		} 
		printf("\n");
	} 
} 

void printf1D(int row, int vector[row]){
	printf("\n");
	for(int i = 0; i < row; i++){
		printf("%d ", vector[i]);
	} 
} 
 

void mmultTests(){
	printf("\n\t Two by two tests\n");
	double m1[2][2] = {{1.0, 2.0}, {3.0,4.0}};
	double m2[2][2] = {{5.0,6.0	}, {7.0, 8.0}};
	double res[2][2];
	mmult(2,2, m1, 2,2, m2, res);
	printf2D(2,2,res);
	printf("\n3 by two x 2 x 3 tests\n\n");
	double mA[3][2] = {{1.0, 2.0}, {3.0,4.0}, {5.0, 6.0} };
	double mB[2][3] = {{7.0,8.0,9.0}, {10.0,11.0,12.0}};
	double res2[3][3];
	mmult(3,2,mA,2,3,mB, res2);
	printf2D(3, 3, res2);
	printf("\n4 by 5 on 5 by 6 tests\n\n");
	double mC[4][5] = {{10,11,12,13.5, 13},
		{14,15,16,17,18.5},
		{19,20,21,21.0, 22},
		{23.0, 25.0, 26, 27, 28}};
	double mD[5][6] = {{50, 51, 52, 53, 54.9, 55},
		   {56.0,57,58,59, 60.0, 61},
		   {62.0, 63,64,65,66,67},
		   {68,69,70.1, 71.0, 72, 73},
		   {74, 75.0,76.2, 77.5, 78, 79}};
	double res3[4][6];
	clock_t t1, t2;
	t1 = clock();
	mmult(4,5,mC, 5,6,mD, res3);
	t2 = clock();
	double tt = (double)(t2-t1) / CLOCKS_PER_SEC;
	printf("\n Time taken %f", tt);
	printf2D(4,6,res3);

} 	

void transposeTests(){
	printf("Transpose tests");
	double m[3][2] = {{1.0, 2.0}, {3.0,4.0}, {5.0, 6.0} };
	double m2[2][3];
	transpose(3, 2, m, m2);
	printf2D(2,3,m2);
	double mA[2][2] = {{1.0, 2.0}, {3.0,4.0}};
	double mB[2][2];
	transpose(2, 2, mA, mB);
	printf2D(2,2,mB);
	double mC[3][4] = {{1.0, 2.0, 8.0, 11}, {3.0,4.0, 9.5, 12}, {5.0, 6.0, 10.1, 13} };
	double mD[4][3];
	transpose(3, 4, mC, mD);
	printf2D(4,3, mD);
	double mE[1][4] = {{1.0, 2.0, 8.0, 11}};
	double mF[4][1];
	transpose(4, 1, mE, mF);
	printf2D(4,1, mF);
	double mG[4][1] = {{1.0}, {2.0},{8.0},{11}};
	double mH[1][4];
	transpose(1, 4, mG, mH);
	printf2D(1,4, mH);
} 	

void fillCofactorTests(){
	printf("\nfillCofactor Tests\n");
	double m[3][3] = {{1.0, 2.00, 8.0}, {3.0,4.0, 2.0}, {5.0, 6.0, 21.0} };
	double m2[2][2];
	fillCofactor(3, m, m2, 2);
	printf2D(2, 2, m2);
} 

void determinantTests(){
	printf("\nDeterminant Tests\n");
	double mA[2][2] = {{1.0, 2.0}, {3.0,4.0}};
	printf("\n2x2 %f \n", determinant(2, mA));
	double mB[4][4] = {{1.0, -2.0, 3.0, 4.0}, {3.0,-4.0, 5.0, 0}, {6.0,7.0,2.0, 1}, {1,-9,2,0}};
	printf("\n4x4 %f \n", determinant(4, mB));
	double g[4][4] = {{1.0, 2.00, 8.0, 3.0}, {3.0,4.0, 2.0, 11.0}, {5.0, 6.0, 1.0, 15.0}, 
		{2.0, 7.0, 1.0, 5.0}};
	printf("\nThe second 4x4 %f \n", determinant(4, g));
	double mC[5][5] = { {1,2,3,4,5.0}, {0.0,7,8,9,10}, {1,1,1,1,1}, {0,1,0,1,0.0}, {2,1,1,2,1} };
	printf("\nthird test 5x5 %f \n", determinant(5, mC));
	double mD[6][6] = { {1,2,3,4,5.0, 6}, {0.0,7,8,9,10, 11.5}, {1,1,1,1,1, 13},
	   	{0,1,0,1,0.0, 50}, {2,1,1,2,1, -10}, {1, 0, 13, -2, 1, -6 }};
	printf("\nFourth test 5x5 %f \n", determinant(6, mD));

} 



