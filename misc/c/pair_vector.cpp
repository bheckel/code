//////////////////////////////////////////////////////////////////////////////
//     Name: pair_vector.cpp
//
//  Summary: Definition.  Track pairs of data (e.g. height and weight)
//           Probably would have been better inlined but this is for demo
//           purposes only.
//
//           Compile e.g.
//           $ g++ -c pair_vector.cpp
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include "pair_vector.h"

double& pair_vect::first_element(int i) {
  return a.element(i);
}


double& pair_vect::second_element(int i) {
  return b.element(i);
}

