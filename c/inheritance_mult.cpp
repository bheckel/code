//////////////////////////////////////////////////////////////////////////////
//     Name: inheritance_mult.cpp
//
//  Summary: Multiple inheritance.  See inheritance_single.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 4.3)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

class CPolygon {
  protected:
    int width, height;
  public:
    void set_values(int a, int b) { width=a; height=b;}
};


////////
class COutput {
  public:
    void output(int i);
};


void COutput::output(int i) {
  cout << i << ", courtesy of COutput::output()" << endl;
}
////////


//                 ----- inherits from both ------
class CRectangle : public CPolygon, public COutput {
  public:
    int area(void) { return(width * height); }
};


//               ----- inherits from both ------
class CTriangle: public CPolygon, public COutput {
  public:
    int area(void) { return(width * height / 2); }
};
  

int main() {
  CRectangle rect;
  CTriangle trgl;

  rect.set_values (4, 5);
  trgl.set_values (4, 5);
  rect.output(rect.area());
  trgl.output(trgl.area());

  return 0;
}
