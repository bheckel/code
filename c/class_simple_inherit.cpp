//////////////////////////////////////////////////////////////////////////////
//     Name: class_simple_inherit.cpp  (see class_simple.h)
//
//  Summary: Demo of using inheritance within a basic, almost useless,
//           class.
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
using namespace std;

// Y will contain all the data elements in X and all the member functions in X.
// In fact, Y contains a subobject of X just as if you had created a member 
// object of X inside Y instead of inheriting from X. 
//
// Specify 'public X' b/c the desired result is to keep all the public members
// of the base class public in the derived class.  Otherwise, must expose their
// names (no args or ret vals) in the public: section of the derived class
// (e.g. X::permute)
//
//     is a
class Y : public X {
  private:
    int i; // different from X's i
  public:
    Y() { i = 0; }
    int change() {
      i = permute(); // different name call
      return i;
    }
    void set(int ii) {  // set() in the base class is redefined here
      i = ii;
      X::set(ii);   // same-name function call, scope resolution operator is
    }               // required
};


int main() {
  // You can see that Y's data elements are combined with X's because the
  // sizeof(Y) is twice as big as sizeof(X).
  cout << "sizeof(X) = " << sizeof(X) << endl;
  cout << "sizeof(Y) = " << sizeof(Y) << endl;

  Y y;

  // Redefined functions hide base versions:
  y.set(5);
  cout << "after y.change(): " << y.change() << endl;

  // X function interface comes through:
  cout << "after y.read(): " << y.read() << endl;
  cout << "after y.permute(): " << y.permute() << endl;
} 
