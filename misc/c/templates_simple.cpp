//////////////////////////////////////////////////////////////////////////////
//     Name: templates_simple.cpp
//
//  Summary: Demo of using macros vs. templates.
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>

// Generic, C-like, function.  Copies B into A.
#define COPY(A, B, N) { int i; for ( i=0; i<(N); ++i ) (A)[i] = (B)[i]; }

// Generic C++ function.  Copies B into A.
template<class T>
void copy(T a[], T b[], int n) {
  for ( int i=0; i<n; ++i )
    a[i] = b[i];
}


int main() {
  char c1[] = { 'a', 'b', 'c' };
  char c2[] = { 'd', 'e', 'f' };
  char c3[sizeof c2];
  int i1[] = { 11, 22, 33 };
  int i2[sizeof i1];

  // Copy regardless of type.  Simple but not type-safe.  Templates are
  // better.
  COPY(c2, c1, 3);
  cout << "1: " << c1[1] << "  " << "2: " << c2[1] << endl;

  COPY(c3, c2, 3);
  cout << "2: " << c2[1] << "  " << "3: " << c3[1] << endl;

  // Template version.
  copy(c1, c3, sizeof c1);
  cout << "1: " << c1[1] << "  " << "3: " << c3[1] << endl;

  copy(i2, i1, sizeof i1);
  cout << "2: " << i2[1] << "  " << "1: " << i1[1] << endl;
}
