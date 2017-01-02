ginclude <stdio.h>	
#include <string.h>

int countWords();
 
int main()
{
	
    int bin1, bin2, bin3, bin4, bin1count, bin2count, bin3count, bin4count, bin5count; 
	bin1=3;
	bin2=6;
	bin3=9;
	bin4=12;
	bin1count=bin2count=bin3count=bin4count=bin5count=0;
	int wl;
    int c;
	wl =0;
	while( (c= getchar()) != EOF)	
	{
		if(c == ' ' || c=='\n')
		{
			if(wl <= bin1){
				bin1count++;
			}	
			else if( (wl <= bin2) && (wl > bin1)){
				bin2count++;
			}
			else if( (wl <= bin3) && (wl > bin2)){
				bin3count++;
			}
			else if( (wl <= bin4) && (wl > bin3)){
				bin4count++;
			}
			else{
				bin5count++;
			}	
		wl= -1;
		}
		wl++;
	}
    int i;
    printf("COUNTS\n");
    printf("%d\n", bin1count);
    printf("%d\n", bin2count);
    printf("%d\n", bin3count);
    printf("%d\n", bin4count);
    printf("%d\n", bin5count);
    char bin1out[bin1count]; 
    char bin2out[bin2count];
    char bin3out[bin3count];
    char bin4out[bin4count];
    char bin5out[bin5count];
    for(i=0; i < bin1count; i++)
    {
        bin1out[i] = '#';
    }
    bin1out[bin1count] = '\0';
    printf("0-3     %s\n", bin1out);
    for(i=0; i < bin2count; i++)
    {
        bin2out[i] = '#';
    } 
    bin2out[bin2count] = '\0';
    printf("4-6     %s\n", bin2out);
    for(i=0; i < bin3count; i++)
    {
        bin3out[i] = '#';
    } 
    bin3out[bin3count] = '\0';
    printf("7-9     %s\n", bin3out);
    for(i=0; i < bin4count; i++)
    {
        bin4out[i] = '#';
    } 
    bin4out[bin4count] = '\0';
    printf("10-12   %s\n", bin4out);
    for(i=0; i < bin5count; i++)
    {
        bin5out[i] = '#';
    } 
    bin5out[bin5count] = '\0';
    printf("<13     %s\n", bin5out);
}


int countWords()
{
    int c, wl;
	while( (c= getchar()) != EOF)	
	{
		if(c == ' ' || c=='\n')
		{
            printf("newword");
		    wl= -1;
		}
		wl++;
	}
    return 1;
} 

