//////////////////////////////////////////////////////////////////////////////
//     Name: inheritance_single.cpp
//
//  Summary: Inheritance allows us to create an object derived from another
//           one, so that it may include some of the other's members plus its
//           own ones. 
//
//           This is a better demo than my others in ~/code/c
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com
//                                     C++ tutorial 4.3)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Both rectangles and triangles can be described by means of only two sides:
// height and base.
class CPolygon {
  protected:   // 'private:' will not compile
    int width, height;
  public:
    void set_values(int a, int b) { width=a; height=b;}
};


//                inherits from (public = same access levels as the base class)
class CRectangle : public CPolygon {
  public:       // ^^^^^^
    int area(void) { return(width * height); }
};


//                inherits from (public = same access levels as the base class)
class CTriangle : public CPolygon {
  public:      // ^^^^^^
    int area(void) { return(width * height / 2); }
};

  
int main() {
  // Users don't need to know anything about class CPolygon (even that it
  // exists).  These 2 objects of classes CRectangle and CTriangle contain all
  // of the members of class CPolygon, i.e. width, height and set_values().
  CRectangle rect;
  CTriangle trgl;

  rect.set_values(4, 5);
  trgl.set_values(4, 5);
  cout << "Area of rectangle: " << rect.area() << endl;
  cout << "Area of triangle: " << trgl.area() << endl;

  return 0;
}
