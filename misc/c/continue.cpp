//////////////////////////////////////////////////////////////////////////////
//     Name: continue.cpp
//
//  Summary:  Break loop example.
//
//  Adapted: Sun 06 Jan 2002 13:12:41 (Bob Heckel --
//                        http://www.cplusplus.com/doc/tutorial/tut2-1.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

int main(void) {
  for ( int n=10; n>0; n-- ) {
    if ( n==5 ) continue;
    cout << n << ", ";
  }
  cout << "FIRE!";
  return 0;
}

// Outputs:
// 10, 9, 8, 7, 6, 4, 3, 2, 1, FIRE!  
