// Fig. 9.8: point2.cpp
// Member functions for class Point
#include "point.h"

// Constructor for class Point.
Point::Point(int a, int b) { 
  setPoint(a, b); 
}


// Set the x and y coordinates.
void Point::setPoint(int a, int b) {
  x = a;
  y = b;
}

// Output the Point.
ostream& operator<<(ostream& output, const Point& p) {
   output << '[' << p.x << ", " << p.y << ']';

   return output;   // enables cascading
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
