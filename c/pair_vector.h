//////////////////////////////////////////////////////////////////////////////
//     Name: pair_vector.h
//
//  Summary: Declaration.  Track pairs of data (e.g. height and weight)
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#ifndef PAIR_VECTOR_H
#define PAIR_VECTOR_H

// Want to include "safe array" functionality in pair_vect objects.
#include "dbl_vect.h"

class pair_vect {
  private:
    dbl_vect a, b;  // pair_vector "has-a" dbl_vect
    int size;
  public:
    pair_vect(int i) : a (i), b (i), size (i) {};
    double& first_element(int i);
    double& second_element(int i);
    int ub() const { return size-1; }
};

#endif
