//////////////////////////////////////////////////////////////////////////////
//     Name: this.cpp
//
//  Summary: The keyword 'this' represents, within a class, the address in
//           memory of the object of that class that is being executed. It is
//           a pointer whose value is always the address of the object.
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut4-2.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

class CDummy {
  public:
    int isitme(CDummy& param);
};


// Check if a parameter passed to a member function of an object is the object
// itself.
int CDummy::isitme(CDummy& param) {
  if ( &param == this ) return 1;
  else return 0;
}

int main() {
  CDummy  a;
  ///CDummy *b = &a;
  CDummy *b;

  b = &a;

  if ( b->isitme(a) )
    cout << "yes, &a is b";

  return 0;
}
