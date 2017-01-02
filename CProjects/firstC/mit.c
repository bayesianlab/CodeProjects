#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char * trythis(char * x){
// 	char *str;
// 	str = (char*)malloc(30);
// 	strcpy(str, "twentycharacters");
// 	return str;

}

int main(void){
	char g[25];
	int n = 10;
	sprintf(g, "%d", n);
	puts(g);
	
	char * pnt;
	printf("%p\n", pnt);
	char x[] = "pi";
	pnt = (char*)&x;
	printf("%s\n", pnt);
	
	return 0;
	
}	