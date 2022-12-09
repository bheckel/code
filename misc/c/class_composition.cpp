//////////////////////////////////////////////////////////////////////////////
//     Name: class_composition.cpp  (see class_simple.h)
//
//  Summary: Demo of using public composition within a basic, almost useless,
//           class.  Does NOT use inheritance.
//
//           Typically you use composition to reuse existing types as part of
//           the underlying implementation of the new type and inheritance
//           when you want to force the new type to be the same type as the
//           base class 
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 14)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "class_simple.h"

class Y {
  private:
    int i;
  public:
    X x;     // embedded object (subobject) from class_simple.h
    Y() { i = 0; }
    void f(int ii) { i = ii; }
    int g() const { return i; }
};


int main() {
  Y y;

  y.f(47);
  cout << "y.g(): " << y.g() << endl;

  y.x.set(37); // access the embedded object
  cout << "y.x.read(): " << y.x.read() << endl;
} 
