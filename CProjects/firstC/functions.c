#include <stdio.h>
#include <string.h>
#include "c_header.h"

void commas(void) {
	
	char buffer[80];
	
	FILE *fp;
	fp = fopen("S+P500.csv", "r");
	while( fgets(buffer, 100, fp) != NULL){
		printf("%s\n", buffer);
	}
	
	fclose(fp);  

  return;
}