//////////////////////////////////////////////////////////////////////////////
//     Name: try_throw_catch.cpp
//
//  Summary: Demo of error handling.  Exceptions.
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.3)
// Modified: Sat 18 Jan 2003 15:26:57 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

void foo() {
  int i;

  i = 15;
  if ( i == 15 )
    i++;
    throw i;
}


int main() {
  try {
    foo();
  }
  // catch() must go right here with no intervening code.
  catch(int n) {
    cout << "Exception caught: " << n << endl;
    ///exit(1);
  }
  // It can be overloaded so that different 'throw's pass different types to
  // be 'catch'ed:
  ///  catch(char* c) {
  ///    cout << "Exception caught: " << c << endl;
  ///  }
  // Or can catch all exceptions regardless of type used in the call to
  // 'throw' by using ellipsis '...'
  ///  catch(...) {
  ///    cout << "Exception caught." << endl;
  ///  }

  cout << "...but the program continues merrily on its way." << endl;

  return 0;
}
