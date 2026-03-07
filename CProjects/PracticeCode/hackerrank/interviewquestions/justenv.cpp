#include <bits/stdc++.h>
#include <stdio.h>
#include <stdlib.h>
/* octal rep */

using namespace std;
int find_max_sum(int *numbers, int size) {
  int largest;
  int second;
  if (size == 1) {
    return *numbers;
  }
  if (*(numbers) > *(numbers + 1)) {
    largest = *numbers;
    second = *numbers + 1;
  } else {
    largest = *(numbers + 1);
    second = *numbers;
  }
  for (int i = 2; i < size; ++i) {
    if (*(numbers + i) > largest) {
      second = largest;
      largest = *(numbers + i);
    } else if (*(numbers + i) > second && *(numbers + i) != largest) {
      second = *(numbers + i);
    }
  }

  return largest + second;
}

int bin(int N) {
  int x;
  int y = 0;
  int i = 1;
  while (N != 0) {
    x = x % 2;
    N = N / 2;
    y = y + x * i;
    i *= 10;
  }
  return y;
}

int copy_bit(int src, int dst, int pos) {
  int x = bin(src);
  int y = bin(dst); 
  char *c;
  int arr1[64] = {0};
  int arr2[64] = {0};

  int i = 0;
  int posnum = 0; 
  while (x > 0) {
    arr1[i] = x % 10;
    x = x / 10;
    ++i;
  }
  i =0;
  while (y > 0) {
    arr2[i] = y % 10;
    y = y / 10;
    ++i;
  }
  posnum = arr1[pos]; 
  arr2[pos] = posnum; 

  int n = 0; 
  for(int i =0; i < 64; ++i){
    p *= p;
    n = arr2[i]*(p)
  }
  return -1;
}

#ifndef RunTests
int main() { printf("%d", copy_bit(7, 12, 3)); }
#endif
