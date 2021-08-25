#include <stdio.h>
#define NROW 3
#define NCOL NROW 


void initPascal();

void printf2D();

int sumArray();

int factorial();

void cUnitInt();

int ibin();

int jbin();

int kbin();

void pascal();

int main(){
	// Test 1
	cUnitInt(factorial(2), 2);
	cUnitInt(factorial(3), 6);
	cUnitInt(factorial(-1), 0);
	cUnitInt(factorial(6), 720);
	cUnitInt(ibin(4,2), 6);
	cUnitInt(jbin(10, 3), ibin(10,3));
	int arrl[] = {
		1,2,3
	} ;
	int arrl2[] = {
		0
	} ;
	cUnitInt(sumArray(arrl, 3), 6);
	cUnitInt(sumArray(arrl2, 1), 0);
	
	int triangle[NROW+1][NCOL+1];
	//pascal(NROW, triangle);
	kbin(4,2);
} 

int factorial(int x){
	if(x < 0){
		printf("Error: must be integer input\n");
		return 0;
	} 
	if(x == 0 || x == 1){
		return 1;
	} 
	else{
		return x * factorial(x-1);
	} 

} 

void cUnitInt(int x, int testVal){
	if(x == testVal){
		printf("PASS, %d == %d\n", x, testVal); 
	}
   else{
		printf("FAIL, %d != %d", x, testVal);
   } 	   
} 

int ibin(int n, int m){
	return factorial(n) / (factorial(m) * factorial(n - m));
} 

int jbin(int n, int m){
	int prod = 1;
	if(m < (n-m)){
		for(int k = 1; k <= m; k++){
			prod = (prod * (n - k + 1)) / k;
		}
	   return prod;	
	} 
	return 1;
} 

int kbin(int n, int m){
	int tri[n + 1][n + 1];
	pascal(n + 1, tri);
	printf("\n%d choose %d = %d\n", n, m, tri[n][m]);
} 

void initPascal(int nrow, int triangle[nrow][nrow]){
	for(int i = 0; i <= 1; i++){
		for(int j = 0; j < nrow; j++){
			if(i == 0 && j == 0){
				triangle[i][j] = 1;
			}
   			else if(i==1 && j == 0){
	   			triangle[i][j] = 1;
   			}	
			else if(i ==1 && j ==1){
				triangle[i][j] = 1;
			} 
			else{
				triangle[i][j] = 0;
			} 		
  	  	} 
 	}
} 

void pascal(int nrow, int triangle[nrow][nrow]){
	initPascal(nrow, triangle);
	for(int i = 2; i < nrow; i++){
		for(int j = 0; j < nrow; j++){
			if(j == 0 || j == i){
				triangle[i][j] = 1;
			}
			else if(j > i){
				triangle[i][j] = 0;
			} 
		    else {
			   triangle[i][j] = triangle[i-1][j-1] + triangle[i-1][j];
		   }
		} 
	}
	printf2D(nrow, nrow, triangle);	
}

void printf2D(int nrow, int ncol, int twoDarr[nrow][ncol]){
	int zerosOff;
	zerosOff = ncol - 1;
	printf("\n");
	for(int i = 0; i < nrow; i++){
		printf("Row %d  ", i);
		for(int j = 0; j < (ncol - zerosOff); j++){
			printf("%d ", twoDarr[i][j]);
		} 
		printf("\n");
		zerosOff--;
	} 
} 

int sumArray(int arrayName[], int arrayLen){
	int sum = 0 ;
	if(arrayLen == 1){
		return arrayName[0];
	} 
	else{
		for(int i = 0; i < arrayLen; i ++){
			sum = sum + arrayName[i]; 
		} 
		return sum;
	} 
} 
