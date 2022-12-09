//////////////////////////////////////////////////////////////////////////////
//     Name: class_w_constructor.cpp
//
//  Summary: Simple class demo but this one uses a constructor (and
//           destructor).  It manipulates ints to calculate area of a
//           rectangle.
//
//           See class.cpp for simpler version.
//
//  Adapted: Mon 07 Jan 2002 18:29:28 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut3-4.html)
// Modified: Wed 27 Aug 2003 20:58:11 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Once declared, the class becomes a valid type, the same as int or char.
class CRectangle {
  public:
    CRectangle(int, int);          // constructor (params passed)
    ///CRectangle(int a, int b);   // same
    CRectangle();                  // constructor (no params)
    ~CRectangle();                 // destructor
    // Only declaring *prototype* for incr_values() at this time.
    void incr_values(int, int);
    // Define the behavior of area() entirely at this time (considered
    // inline by the compiler).
    // This only works when not using destructor.
    ///int area(void) { return(width*height); }
    // Since we're using a destructor, do this:
    int area(void) { return(*width * *height); }
  private:
    // This only works when not using destructor.
    ///int width, height;
    // Since we're using a destructor, do this:
    int *width, *height;
};  // <---easy-to-forget semicolon just like structs


// This only works when not using destructor.
///void CRectangle::incr_values(int a, int b) {
///  width  = ++a;
///  height = ++b;
///}
// Since we're using a destructor, do this:
void CRectangle::incr_values(int a, int b) {
  // The class CRectangle "knows", exclusively, about variables width and
  // height.
  *width  = ++a;
  *height = ++b;
}



// No void (nor any type) return value is used for *constructors*.
CRectangle::CRectangle(int a, int b) {
  // These 2 only work when not using destructor.
  ///x = a;
  ///y = b;
  // Since we're using a destructor, do this:
  width = new int;
  height = new int;

  // Must use ptr.
  *width  = a;
  *height = b;
}


// Overloaded constructor (used only if no params are passed):
// No void (nor any type) return value is used for *constructors*.
CRectangle::CRectangle() {
  width  = new int;
  height = new int;

  *width  = 9;
  *height = 10;
}



// Destructor frees memory.
// TODO how to tell what is being destroyed (and print it out)?
CRectangle::~CRectangle() {
  delete width;
  delete height;
  cout << "variable width and/or variable height destroyed" << endl;
}


int main(void) {
  // Create 4 CRectangle objects.
  CRectangle  rect_object1(7, 6);   // instance #1 (normal)
  CRectangle  rect_object2(8, 9);   // instance #2 (normal)
  ///CRectangle rect_object3();     // wrong!
  CRectangle  rect_object3;         // instance #3 (use defaults 9 and 10)
  CRectangle *prect_object4;        // instance #4 (a ptr to type CRectangle)

  cout << "area 1: " << rect_object1.area() << endl;
  rect_object1.incr_values(1, 2);
  cout << "area 1 now: " << rect_object1.area() << endl << endl;

  cout << "area 2: " << rect_object2.area() << endl << endl;

  cout << "area 3 (no params passed): " << rect_object3.area() << endl << endl;

  // Using pointers requires this additional gyration:
  ///prect_object4 = new CRectangle;     // ok
  prect_object4 = new CRectangle(2, 5);
  // Note '->' instead of '.'
  cout << "area 4 (ptr): " << prect_object4->area() << endl << endl;

  cout << "Preparing destruction...  Have a nice day." << endl;

  return 0;
}
