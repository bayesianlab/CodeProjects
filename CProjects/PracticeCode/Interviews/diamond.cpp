#include <bits/stdc++.h>

using namespace std;

class base {
    public:
    void whoami() {
        cout << "base" << endl;
    }
};


class subclass1 : public base {
    public:
    void whoami() {
        cout << "subclass1" << endl;
    }
};

class A {
public:
    void show() { std::cout << "A\n"; }
    int value = 42;
};

class B : public A { };
class C : public A { };

class D : public B, public C { 
public:

};



int main() {

    base b = base();

    subclass1 sub1 = subclass1();

    b.whoami();

    sub1.whoami();

    base* bptr;
    bptr = new subclass1();
    bptr->whoami();

    cout << "Question 2" << endl;

    D d;
    cout << "d show" << endl;
    //d.show();   


}