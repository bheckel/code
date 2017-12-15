//////////////////////////////////////////////////////////////////////////////
//     Name: virtual.cpp
//
//  Summary: In order to declare an element of a class which we are going to
//           redefine in derived classes we must precede it with the keyword
//           'virtual' so that pointers to objects of that class are suitable.
//
//           See abstract_base_class.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 4.4)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Base class (not abstract).
class CPolygon {
  protected:
    int width, height;
  public:
    void set_values(int a, int b) { width=a; height=b; }
    // After adding this line, the three classes (CPolygon, CRectangle and
    // CTriangle) have the same members: width, height, set_values() and
    // area().  area() has been defined as virtual because it is later
    // redefined in derived classes.
    // What the word 'virtual' does is allow the member of a derived class
    // with the same name to be used as one of the base classes to be called
    // when a *pointer* to it is used.
    virtual int area(void) { return(0); }
    // Abstract base class would instead use:
    ///virtual int area(void) =0;   // a pure virtual function
    // but CPolygon poly; and CPolygon *ppoly3 = &poly; in main() would have
    // to be removed because there cannot be created instances (objects) of
    // CPolygon in abstract base classes.
  };


// Derived class.
class CRectangle: public CPolygon {
  public:
    int area(void) { return(width * height); }
  };


// Derived class.
class CTriangle: public CPolygon {
  public:
    int area(void) { return(width * height / 2); }
  };


int main() {
  CRectangle rect;
  CTriangle trgl;
  CPolygon poly;
  CPolygon *ppoly1 = &rect;
  CPolygon *ppoly2 = &trgl;
  CPolygon *ppoly3 = &poly;
  ///CPolygon *ppoly3;

  ///ppoly3 = &poly;

  ppoly1->set_values(4,5);
  ppoly2->set_values(4,5);
  ppoly3->set_values(4,5);
  cout << ppoly1->area() << endl;  // virtual, use CRectangle's area()
  cout << ppoly2->area() << endl;  // virtual, use CTriangle's area()
  cout << ppoly3->area() << endl;  // virtual, use CPolygon's area()

  return 0;
}
