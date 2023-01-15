#include <iostream>

using namespace std;
class Base {
 public:
 // Declaring virtual means that this function can be bound at 
 // runtime. Without the compiler would bind display only to Base
 // and if the pointer was assigned a new address Base display would 
 // still be called. Now the display function is flexible to apply to
 // different classes when the pointer is reassigned to a new class. 
  virtual void display() { cout << "Base class called" << endl; }
};

class A : public Base {
 public:
 // Automatically considered virtual
  void display() { cout << "A class called" << endl; }
};

class B : public Base {
 public:
 // Automatically considered virtual
  void display() { cout << "B class called" << endl; }
};

int main() {
  Base b; 
  b.display();
  Base *x; 
  A a; 
  x = &a; 
  x->display(); 

  return 0;
}