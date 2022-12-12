// Fig. 9.8: point2.h
// Definition of class Point
#ifndef POINT_H
#define POINT_H

#include <iostream>

using std::ostream;

class Point {
   friend ostream& operator<<(ostream& , const Point&);
public:
   Point(int = 0, int = 0);        // default constructor
   void setPoint(int, int);        // set coordinates
   int getX() const { return x; }  // get x coordinate
   int getY() const { return y; }  // get y coordinate
protected:        // accessible to derived classes
   int x, y;      // coordinates of the point
};

#endif


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
