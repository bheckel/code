/*
*****************************************************************************
*     Name: stringize.cpp
* 
*  Summary: Demo of stringizing.  Useful for debugging.
*
*  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
*****************************************************************************
*/
#include <iostream>
#include <cassert>
using namespace std;

#define P(A) cout << #A << ": " << (A) << endl;

int main() {
  int a = 1, b = 2, c = 3;

  // $ g++ -DNDEBUG stringize.cpp   to disable for production.
  assert(a == 1);   // optional double check for expected values

  P(a); P(b); P(c);
  P(a + b);
  // Switch debugging off at an arbitrary point.
  #define P(A) NULL
  P((c - a) / b);
} 
