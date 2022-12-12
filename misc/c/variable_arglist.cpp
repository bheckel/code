// Fig. 18.2: fig18_02.cpp
// Using variable-length argument lists
#include <iostream>

using std::cout;
using std::endl;
using std::ios;

#include <iomanip>

using std::setw;
using std::setprecision;
using std::setiosflags;

#include <cstdarg>    // for variable args

double average(int, ...);


int main() {
  double w = 37.5, x = 22.5, y = 1.7, z = 10.2;

  cout << setiosflags(ios::fixed | ios::showpoint) 
       << setprecision(1) << "w = " << w << "\nx = " << x 
       << "\ny = " << y << "\nz = " << z << endl;

  cout << setprecision(3) << "\nThe average of w and x is "
       << average( 2, w, x ) 
       << "\nThe average of w, x, and y is " 
       << average(3, w, x, y) 
       << "\nThe average of w, x, y, and z is " 
       << average(4, w, x, y, z) << endl;

  return 0;
}


double average(int i, ...) {
  double total = 0;
  va_list ap;

  va_start(ap, i);

  for ( int j = 1; j <= i; j++ )
     total += va_arg(ap, double);

  va_end(ap);

  return total / i;
}




/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
