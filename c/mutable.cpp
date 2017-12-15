//////////////////////////////////////////////////////////////////////////////
//     Name: mutable.cpp
//
//  Summary: Demo simple use of mutable.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus v4
//                                     Stephen Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

struct data {
  char name[30];
  mutable int accesses;  // shield vari accesses from any const restrictions
};


int main() {
  const data mydatastruct = { "Testing User", 42 };

  ///strcpy(mydatastruct.name "Changed Tothis");  // not allowed
  cout << ++mydatastruct.accesses;                // ok

  return 0;
}
