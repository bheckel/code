//////////////////////////////////////////////////////////////////////////////
//     Name: abstract_base_class.cpp
//
//  Summary: Create a function member of CPolygon (i.e. printanyarea()) that
//           is able to print the result of the area() function independently
//           of which of the derived classes is calling it.
//
//           See virtual.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 4.4)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Abstract base class (because of the =0 below).
class CPolygon {
  protected:
    int width, height;
  public:
    void set_values(int a, int b) { width=a; height=b; }
    // Not specifying an implementation for this function.  So it's a pure
    // virtual function.  And polymorphic.
    virtual int area(void) =0;
    //                    ^^^
    // 'this' represents a pointer to the object whose code is being executed.
    void printanyarea(void) { cout << this->area() << endl; }
};


//        inherits from
class CRectangle : public CPolygon {
//              ^^^
  public:
    int area(void) { return(width * height); }

};


class CTriangle:public CPolygon {
  public:
    int area(void) { return(width * height / 2); }
};


int main() {
  CRectangle rect;
  CTriangle trgl;
  ///CPolygon poly;    // not allowed due to abstract base class
  CPolygon *ppoly1 = &rect;
  CPolygon *ppoly2 = &trgl;

  // Old style still available:
  rect.set_values(6, 7);
  // But have to do your own printing.
  cout << "no pointers: " << rect.area() << endl;

  // Better:
  ppoly1->set_values(4, 5);
  ppoly2->set_values(4, 5);
  ppoly1->printanyarea();
  ppoly2->printanyarea();

  return 0;
}
