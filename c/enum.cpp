//////////////////////////////////////////////////////////////////////////////
//     Name: enum.cpp
// 
//  Summary: Demo of enum.  Doesn't work in C.  It is a natural way of 
//           representing a limited domain of values.  Not used frequently in
//           C++ (better approaches exist).
//
//           Use enums when you know ALL the possible values of a variable and
//           want to express them in words.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
// Modified: Thu 15 Apr 2004 13:06:07 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <cstdio>

// If you plan to use just the constants and not create variables of the enum
// type, you can omit an enumeration type name like ShapeEnum.
// 
// Sometimes it's a good idea to use a group prefix the same as the name of
// the enum (e.g.  ShapeEnum_circle, ShapeEnum_circleclone...) to make clear
// that members of the type belong to the same group.
enum ShapeEnum {
  circle,           // 0
  circleclone = 0,  // 0
  square = 42,
  rectangle         // 43
};  // must end with a semicolon like a struct


int main(void) {
  ShapeEnum myshape;

  // DEBUG
  ///myshape = square;
  myshape = rectangle;

  // Now do something based on what the shape is.
  switch ( myshape ) {
    case circle:
         printf("circle is %d\n", myshape);
         break;
    case square:
         printf("square is %d\n", myshape);
         break;
    case rectangle:
         printf("rectangle is %d\n", myshape);
         break;
  }

  return 0;
} 
