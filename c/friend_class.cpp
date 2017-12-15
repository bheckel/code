//////////////////////////////////////////////////////////////////////////////
//     Name: friend_class.cpp
//
//  Summary: Define a class as friend of another one, allowing that the second
//           one accesses to the protected and private members of the first
//           one. 
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 4.3)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// The definition of CSquare is included later, so if we did not include a
// declaration for CSquare here, the class would not be visible from within
// the definition of CRectangle. 
class CSquare;

// Based on the way class CSquare has been setup, CRectangle can access
// private members of CSquare.
class CRectangle {
  public:
    int area(void) { return(width*height); }  // defined now
    void convert(CSquare a);                  // defined later
  private:
    int width, height;
};


// CSquare can't access CRectangle unless CRectangle adds a line: 
// friend class CSquare;
class CSquare {
  public:
    void set_side(int a) { side=a; }
    friend class CRectangle;  // CRectangle is a friend of CSquare
  private:
    int side;  // CSquare::side is not private to CRectangle
};


void CRectangle::convert(CSquare a) {
  width  = a.side;
  height = a.side;
}

  
int main() {
  CSquare sqr;
  CRectangle rect;

  sqr.set_side(4);
  rect.convert(sqr);
  cout << rect.area() << endl;

  return 0;
}
