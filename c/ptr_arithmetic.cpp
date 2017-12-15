//////////////////////////////////////////////////////////////////////////////
//     Name: ptr_arithmetic.cpp
// 
//  Summary: Demo of pointer arithmetic.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

// Preprocessor feature called stringizing (implemented with the '#' sign
// before an expression) that takes any expression and turns it into a
// character array. 
#define PRINTME(EX) cout << #EX << ":\t " << EX << endl;

int main() {
  int a[10];

  for ( int i=0; i<10; i++ )
    a[i] = i; // give array index values

  int *ip = a;

  PRINTME(*ip);
  PRINTME(*++ip);
  PRINTME(*(ip + 5));

  int *ip2 = ip + 5;

  PRINTME(*ip2);
  PRINTME(*(ip2 - 4));
  PRINTME(*--ip2);
  PRINTME(ip2 - ip); // Yields number of elements
} 
