//////////////////////////////////////////////////////////////////////////////
//     Name: default_args.cpp
//
//  Summary: Default values in functions.
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut2-3.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

int divide(int a, int b=2) {
  int r;

  r = a/b;

  return(r);
}

int main(void) {
  cout << divide(12);
  cout << endl;
  cout << divide(20,4);

  return 0;
}

