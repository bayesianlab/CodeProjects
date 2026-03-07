#include <stdio.h>

void counter(int stories, int& c) {
  if (stories == 0) {
    c += 1;
    return;

  } else if (stories < 0) {
    return;
  } else {
    counter(stories - 1, c);
    counter(stories - 2, c);
  }
}

int numberOfArrangements(int numberOfStories) {
  int arr[numberOfStories]; 
  arr[0] = 1;
  arr[1] = 2; 
  for(int i = 2; i < numberOfStories; ++i){
    arr[i] = arr[i-1] + arr[i-2]; 
  }
  return arr[numberOfStories-1];
}

#ifndef RunTests
int main() {
  printf("Number of arrangements for 3 stories = %d\n", numberOfArrangements(3));
  
}
#endif