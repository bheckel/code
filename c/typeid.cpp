//////////////////////////////////////////////////////////////////////////////
//     Name: typeid.cpp
//
//  Summary: Check the type of an expression.
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.4)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>
#include <typeinfo>

class CDummy {};


int main() {
  CDummy *a, b;

  if ( typeid(a) != typeid(b) ) {
    cout << "a and b are of different types:\n";
    cout << "a is: " << typeid(a).name() << '\n';
    cout << "b is: " << typeid(b).name() << '\n';
  }

  return 0;
}
