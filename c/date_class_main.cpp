// Fig. 8.6: fig08_06.cpp
// Adapted: Sun Feb 23 20:33:47 2003 (Bob Heckel)
// Driver for class Date
#include <iostream>

using std::cout;
using std::endl;

#include "date_class.h"

int main() {
  Date d1, d2(12, 27, 1992), d3(0, 99, 8045);
  cout << "d1 is " << d1
       << "\nd2 is " << d2
       << "\nd3 is " << d3 << "\n\n";

  cout << "d2 += 7 is " << ( d2 += 7 ) << "\n\n";

  d3.setDate(2, 28, 1992);
  cout << "  d3 is " << d3;
  cout << "\n++d3 is " << ++d3 << "\n\n";

  Date d4(3, 18, 1969);

  cout << "Testing the preincrement operator:\n"
       << "  d4 is " << d4 << '\n';
  cout << "++d4 is " << ++d4 << '\n';
  cout << "  d4 is " << d4 << "\n\n";

  cout << "Testing the postincrement operator:\n"
       << "  d4 is " << d4 << '\n';
  cout << "d4++ is " << d4++ << '\n';
  cout << "  d4 is " << d4 << endl;

  return 0;
}



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
