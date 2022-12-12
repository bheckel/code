//////////////////////////////////////////////////////////////////////////////
//     Name: class.cpp
//
//  Summary: Extremely simple class demo.  Compare with
//           class_w_constructor.cpp
//
//           Peter Van der Linden suggestion:
//             Availability (access specifiers) keywords should all start 
//             with 'p' to increase the lexical orthogonality.
//             private
//             public
//             protected
//             friend s/b protege
//             virtual s/b placeholder
//
//             pure should instead mean empty
//
//  Adapted: Mon 07 Jan 2002 18:29:28 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut3-4.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

class Rectangle {
  public:  // public interface
    // Only declaring prototype at this time.
    void set_values(int,int);
    // Defined the behavior of area() entirely at this time (considered
    // inline).  OK for this to come before x and y are declared.
    ///int area(void) { return(x*y); }
    // Better
    inline int area(void) { return(x*y); }
  private:  // private interface
    int x, y;
};

void Rectangle::set_values(int a, int b) {
  x = a;
  y = b;
}


int main(void){
  Rectangle robj1;   // instance 1
  Rectangle robj2;   // instance 2

  // Not using a constructor.
  robj1.set_values(7, 6);
  cout << "object 1 area: " << robj1.area() << endl;

  robj2.set_values(8, 9);
  cout << "object 2 area: " << robj2.area() << endl;

  return 0;
}
