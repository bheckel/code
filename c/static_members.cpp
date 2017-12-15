//////////////////////////////////////////////////////////////////////////////
//     Name: static_members.cpp
//
//  Summary: Static data members of a class are also known as "class
//           variables", because their content does not depend on any object.
//           There is only one unique value for all the objects of that same
//           class. 
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut4-2.html)
//////////////////////////////////////////////////////////////////////////////

#include <iostream.h>

class CDummy {
  public:
    static int n;
    CDummy() { n++; };
    ~CDummy() { n--; };
};


// According to ANSI-C++ standard, we can only include the protype
// (declaration) in the class declaration but not the definition
// (initialization).   So we do it here:
int CDummy::n=0;


int main() {
  CDummy  a;
  CDummy  b[5];
  CDummy *c = new CDummy;

  // Because it is a unique variable for all the objects of the same class,
  // the static variable can be referred as a member of any object of that
  // class or even *directly* by the class name (of course this is only valid
  // for static members): 
  cout << a.n << endl;  // member of object a (static variable n)
  cout << CDummy::n;    // direct class name (static variable n)
  delete c;
  cout << endl << CDummy::n << endl;

  return 0;
}
