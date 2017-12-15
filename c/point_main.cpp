// Fig. 9.8: fig09_08.cpp
// Driver for class Point
#include <iostream>

using std::cout;
using std::endl;

#include "point.h"

int main() {
  Point p(72, 115);   // instantiate Point object p
  Point q;

  // Protected data of Point inaccessible to main so do it this way.
  cout << "X coordinate is " << p.getX()
       << "\nY coordinate is " << p.getY();

  p.setPoint(10, 11);
  cout << "\n\nThe new location of p is " << p << endl;

  cout << "\nq is " << q << endl;

  return 0;
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
