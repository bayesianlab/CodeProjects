#include <iostream>

using namespace std;

class Base {
 public:
  void display() { cout << "Base class called" << endl; }
};

class A : virtual public Base {
 public:
  void display() { cout << "A class called" << endl; }
};

class B : virtual public Base {
 public:
  void display() { cout << "B class called" << endl; }
};

class Derived : public A, public B {
 public:
  void display() { cout << "Derived class called" << endl; }
};

int main() {
  Base b;
  b.display();

  Derived d;
  d.display();
  Base *g; 
  g = new Derived(); 
  

  

  return 0;
}