#include <bits/stdc++.h>


using namespace std;
int main () {

    int y = 100;
    int z = 99;

    int* c;
    
    const int* x; // the value that x is pointing to cannot be changed
    x = &y;
    c = &y;
    x = &z;

    // *x = 5; not modifiable lvalue
    *c = 5; // regular pointers can have their values changed


    cout << *x << endl;
    cout << *c << endl;



    int* const q = &y; 

    cout << *q << endl;

    *q = 8;

    cout << *q << endl;

    // q = &z;  not modifable lvalue

}