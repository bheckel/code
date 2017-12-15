//////////////////////////////////////////////////////////////////////////////
//     Name: union.cpp
// 
//  Summary: Demo of a memory-saving union.  Handle different types of data
//           using the same variable.  Using a struct would be a
//           memory-hogging alternative.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

union Packed { // Declaration similar to a class
  char   i;
  short  j;
  int    k;
  long   l;
  float  f;
  double d;  
  // The union will be the size of a double, since that's the largest element.
};  // semicolon ends a union, like a struct

int main() {
  cout << "sizeof(Packed) = " << sizeof(Packed) << endl;
  Packed x;
  x.i = 'a';
  cout << x.i << endl;
  x.d = 3.14159;
  cout << x.d << endl;
} 
