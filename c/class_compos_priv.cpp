//////////////////////////////////////////////////////////////////////////////
//     Name: class_composition_priv.cpp  (see class_simple.h)
//
//  Summary: Demo of using public composition within a basic, almost useless,
//           class.  Does NOT use inheritance.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 14)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "class_simple.h"

class Y {
  private:
    int i;
    X x;     // embedded object
  public:
    Y() { i = 0; }
    void f(int ii) { i = ii; x.set(ii); }
    int g() const { return i * x.read(); }
    int xread() { x.read(); }
    void permute() { x.permute(); }
};

int main() {
  Y y;

  y.f(2);   // set
  cout << "y.xread() after setting but before permute(): " << y.xread() 
                                                                    << endl;

  y.permute();
  cout << "y.xread() after permute(): " << y.xread() << endl;

  cout << "y.g(): " << y.g() << endl;  // class Y specific function
} 
