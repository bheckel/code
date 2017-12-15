//////////////////////////////////////////////////////////////////////////////
//     Name: dbl_vect.cpp
//
//  Summary: Implementation of a safe array type.
//
//           Compile e.g.
//           $ g++ -c dbl_vect.cpp
//           $ g++ dbl_vect.o dbl_vect_main.cpp
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include "dbl_vect.h"

// Build a dynamically allocated array.
dbl_vect::dbl_vect(int n) : size (n) {
  assert(n > 0);
  p = new double[size];
  assert(p != 0);
}


// Fill an array element with an integer.
double& dbl_vect::element(int i) {
  assert(i>=0 && i<size);
  return p[i];
}


void dbl_vect::print() const {
  cout << "Vector of size " << size << endl;
  for ( int i=0; i<size; i++ )
    cout << "Element " << i << " holds " << p[i] << "\n";
} 
