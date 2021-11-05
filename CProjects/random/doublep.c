#include <stdio.h>
#include <stdlib.h>

int main()
{

    char **y = (char**)malloc(2*sizeof(char *));
    char *x = "one";
    (y[0]) =  x;
    printf("%s\n", y[0]);
    x = "two";
    y[1] = x;
    printf("%s\n", y[0]);
    printf("%s\n", y[1]);

    // for(int i = 0; i < 2; ++i)
    // {
    // }

}