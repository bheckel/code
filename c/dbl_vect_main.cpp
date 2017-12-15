//////////////////////////////////////////////////////////////////////////////
//     Name: dbl_vect_main.cpp
//
//  Summary: Demo of a linear vector type (a.k.a. a safe array).
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
using namespace std;
#include <string>
#include "dbl_vect.h"  // holds declarations only in this case (as it should)

int main() {
  dbl_vect v(3);  // want an array with 3 elements

  v.element(0) = 66.99;
  // v.element(1) will be (properly) initialized to zero.
  v.element(2) = 42;
  v.print(); 
}
