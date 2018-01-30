#include <math.h>
#include <iostream>
#include "stat225main.hpp"

using namespace std;

int main(int argc, char *argv[]) {
  if (argv[1] != NULL) {
    double y = atof(argv[1]);
    double r = simpleFunc(y);
    cout << r << endl;
    return 1;
  } else {
    return 1;
  }
}

