#include <stdio.h>
#include <stdlib.h>


int main() {
	char buffer[10];
	FILE *fp;
	puts("somthing happened");
	fp = fopen("test.txt", "r");
	fgets(buffer, 10, fp);
	puts(buffer);
//	while(!feof(fp)){
//		fgets(buffer, 1000, fp);
//		puts(buffer);
//	}
//	fclose(fp);
return 0;


}