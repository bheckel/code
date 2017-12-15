//////////////////////////////////////////////////////////////////////////////
//     Name: byreference.cpp
//
//  Summary: Return more than one value.  Only in C++.
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut2-3.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// pass by:      val      ref        ref
void prevnext(int x, int& prev, int& next) {
  prev = x - 1;
  next = x + 1;

  x++;  // prove that x is passed by value
}


int main() {
  int x = 100, y, z;

  prevnext(x, y, z);
  cout << "x=" << x << ", y=" << y << ", z=" << z;
}
