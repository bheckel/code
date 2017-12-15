//////////////////////////////////////////////////////////////////////////////
//     Name: new_delete_dynamic.cpp
//
//  Summary: Demo new, delete dynamic allocation.
//           new and delete are only found in C++ (see malloc for C)
//
//  Adapted: Mon 07 Jan 2002 18:29:28 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut3-4.html)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>
#include <stdlib.h>

// rememb-o-matic
int main(void) {
  char input[100];
  int i, n;
  long * l, total=0;

  cout << "How many numbers do you want to type in? ";

  cin.getline(input,80); 
  i = atoi(input);

  // Request to the system as much space as it is necessary to store all the
  // numbers that the user wishes to introduce.
  l = new long[i];

  // Check for errors while assigning memory dynamically.  Assumes 
  // #define NULL 0 
  // exists somewhere.
  if ( l == NULL ) exit(1);

  for ( n=0; n<i; n++ ) {
    cout << "Enter number: ";
    cin.getline(input,80); 
    l[n] = atol(input);
  }

  cout << "You have entered: ";
  for ( n=0; n<i; n++ )
    cout << l[n] << ", ";

  delete [] l;

  return 0;
}
