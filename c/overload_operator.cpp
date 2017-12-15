//////////////////////////////////////////////////////////////////////////////
//     Name: overload_operator.cpp
//
//  Summary: Overloaded the '+' operator.  Sum the bidimensional vectors
//           a(3,1) and b(1,2).  In this case the result will be 
//           (3+1,1+2) = (4,3). 
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut4-2.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

class CVector {
  public:
    int x,y;
    CVector() {};               // noop constructor
    ///CVector() { x=0; y=0 };  // noop constructor (better)
    CVector(int,int);           // constructor
    CVector operator+(CVector); // function operator+ that returns CVector type
};


// Constructor.
CVector::CVector(int a, int b) {
  x = a;
  y = b;
}


CVector CVector::operator+(CVector param) {
  CVector temp;

  temp.x = x + param.x;
  temp.y = y + param.y;

  return(temp);
}


int main() {
  CVector a(3,1);
  CVector b(1,2);
  CVector c;

  c = a + b;  // not the normal '+'
  cout << c.x << "," << c.y;

  return 0;
}
