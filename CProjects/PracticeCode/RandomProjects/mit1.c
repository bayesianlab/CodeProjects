#include <stdio.h>

int main() { 
  int* xp, yp; 
  int z; 
  xp = &z; 
  yp = xp; 
  *xp = *yp; 
  printf( "%p", ( void * ) &xp ); 
  printf( "%p", ( void * ) &yp );
  \n
  return 0;
}

