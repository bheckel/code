//////////////////////////////////////////////////////////////////////////////
//     Name: dbl_vect.h
//
//  Summary: Declaration of a safe array type.
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#ifndef DBL_VECT_H
#define DBL_VECT_H

#include <iostream>
#include <assert.h>

class dbl_vect {
  private:
    double* p;
    int size;
  public:
    ///dbl_vect(int n=10);
    // Better
    explicit dbl_vect(int n=10);
    ~dbl_vect() { delete []p; }
    double& element(int i);     // access p[i]
    ///int ub() const { return (size-1); }  // upper bound
    // Better
    inline int ub() const { return (size-1); }  // upper bound
    void print() const;
};

#endif
