//////////////////////////////////////////////////////////////////////////////
//     Name: 
//
//  Summary: 
//
//  Created: 
//////////////////////////////////////////////////////////////////////////////

#include <iostream>

int main(void) {
  int in;
  int i;
  int factorial = 1;

  std::cout << "Enter num: ";
  std::cin >> in;
  for ( i=2 ; i < in; ++i )
    factorial = factorial * i;
  factorial = factorial * in;
  std::cout << "here " << factorial << std::endl;

  return 0;
}
