//////////////////////////////////////////////////////////////////////////////
//     Name: pair_vector_main.cpp
//
//  Summary: Track pairs of data (e.g. height and weight)
//
//           Compile e.g.
//           $ g++ dbl_vect.o pair_vector.o pair_vector_main.cpp
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "pair_vector.h"

int main() {
  int i;
  pair_vect age_weight(5);  // 5 pairs of age-to-weight data

  cout << "Table of age and weight\n";
  for  ( i=0; i<=age_weight.ub(); ++i ) {
    age_weight.first_element(i) = 21+i;
    age_weight.second_element(i) = 140+i;
    cout << age_weight.first_element(i) << ", " 
         << age_weight.second_element(i) << endl;
  }
}
