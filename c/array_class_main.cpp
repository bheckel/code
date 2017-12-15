// Modified: Sun 16 Feb 2003 15:36:54 (Bob Heckel)
// To compile:
// $ g++ -c array.cpp && g++ array.o array_main.cpp
// Fig. 8.4: fig08_04.cpp
// Driver for simple class Array
#include <iostream>
using std::cout;
using std::cin;
using std::endl;

#include "array_class.h"

int main() {
  // No objects yet.
  cout << "# of arrays instantiated = " << Array::getArrayCount() << '\n';

  // Create two arrays and print the Array count.
  Array integers1(2), integers2;
  cout << "# of arrays instantiated = " << Array::getArrayCount() << "\n\n";

  // Print integers1 size and contents.
  cout << "Size of array integers1 is "
       << integers1.getSize()
       << "\nArray after initialization:\n"
       << integers1 << '\n';

  // Print integers2 size and contents.
  cout << "Size of array integers2 is "
       << integers2.getSize()
       << "\nArray after initialization:\n"
       << integers2 << '\n';

  // Input and print integers1 and integers2.
  cout << "Input 5 integers (2 for integers1[] and 3 for integers2[]), "
       << "pressing enter after each:\n";
  cin >> integers1 >> integers2;
  cout << "After input, the arrays contain:\n"
       << "integers1:\n" << integers1
       << "integers2:\n" << integers2 << '\n';

  // Use overloaded inequality (!=) operator.
  cout << "Evaluating: integers1 != integers2\n";
  if ( integers1 != integers2 )
     cout << "They are not equal\n";

  // Create array integers3 using integers1 as an initializer; print size and
  // contents.
  Array integers3(integers1);

  cout << "\nSize of array integers3 is "
       << integers3.getSize()
       << "\nArray after initialization:\n"
       << integers3 << '\n';

  // Use overloaded assignment (=) operator.
  cout << "Assigning integers2 to integers1:\n";
  integers1 = integers2;
  cout << "integers1:\n" << integers1
       << "integers2:\n" << integers2 << '\n';

  // Use overloaded equality (==) operator.
  cout << "Evaluating: integers1 == integers2\n";
  if ( integers1 == integers2 )
     cout << "They are equal\n\n";

  // Use overloaded subscript operator to create rvalue.
  cout << "integers1[1] is " << integers1[1] << '\n';

  // Use overloaded subscript operator to create lvalue.
  cout << "Assigning 1000 to integers1[2]\n";
  integers1[2] = 1000;
  cout << "integers1:\n" << integers1 << '\n';

  // Attempt to use out of range subscript.
  ///integers1[15] = 1000;  // ERROR: out of range

  return 0;
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
