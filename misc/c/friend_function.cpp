//////////////////////////////////////////////////////////////////////////////
//     Name: friend_function.cpp
//
//  Summary: In order to allow an external function to have access to the
//           private and protected members of a class we have to declare the
//           prototype of the external function that will gain access preceded
//           by the keyword 'friend' within the class declaration that shares
//           its members. 
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com C++
//                                     tutorial 4.3)
//////////////////////////////////////////////////////////////////////////////

#include <iostream.h>

class CRectangle {
  public:
    void set_values(int, int);
    int area(void) { return(width * height); }
    friend CRectangle doubleit(CRectangle);
  private:  // except to friends
    int width, height;
};


void CRectangle::set_values(int a, int b) {
  width  = a;
  height = b;
}


// This function is *not* a member of class CRectangle.  It just returns a
// CRectangle type.
CRectangle doubleit(CRectangle rectparam) {
  CRectangle rectres;

  rectres.width  = rectparam.width*2;
  rectres.height = rectparam.height*2;

  return(rectres);
}


int main() {
  CRectangle rect, rectb;

  rect.set_values(2,3);
  rectb = doubleit(rect);
  cout << rectb.area();

  return 0;
}
