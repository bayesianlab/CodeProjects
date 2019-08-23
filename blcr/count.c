#include <stdio.h>
#include <string.h>

char hostname[128];

int main()
{
  int i;
  
  printf("Counting demo starting with pid=(%d)\n", (int)getpid());
  
  for (i=1; i<=180;++i) {
    gethostname( hostname, sizeof hostname );
    printf("[%s]  Count = %d\n", hostname, i );
    sleep(1);
  }
}
