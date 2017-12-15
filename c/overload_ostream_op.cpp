//////////////////////////////////////////////////////////////////////////////
//     Name: overload_ostream_op.cpp
//
//  Summary: Demo of operator overloading.
//
//  Adapted: Wed 26 Feb 2003 15:23:52 (Bob Heckel -- http://www.glenmccl.com/)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>

enum E {e1 = 27, e2 = 37, e3 = 47};

// Prevent the actual numbers from printing, instead print e1, e2...
ostream& operator<<(ostream& os, E e) { 
  char* s;

  switch (e) {
    case e1:
            s = "it is e1";
            break;
    case e2:
            s = "it is e2";
            break;
    case e3:
            s = "it is e3";
            break;
    default:
            s = "badvalue";
            break;
   }

   return os << s;
}


int main() {
  enum E x;

  x = e3;

  cout << x << "\n";
  cout << e1 << "\n";
  cout << e2 << "\n";
  cout << e3 << "\n";
  cout << E(0) << "\n";

  return 0;
}
