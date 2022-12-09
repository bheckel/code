// Fig. 19.9: fig19_09.cpp
// Converting to C-style strings.
#include <iostream>

using std::cout;
using std::endl;

#include <string>

using std::string;

int main() {
  string s("STRINGS");
  const char *ptr1 = 0;
  int len = s.length();
  char *ptr2 = new char[len+1]; // including null
  
  // Copy characters out of string into the allocated memory.
  s.copy(ptr2, len, 0);
  ptr2[len] = 0;  // add null terminator

  cout << "C++ string s is " << s 
       << "\nC++ string s converted to a C-style string is "
       << s.c_str();

  // Assign to pointer ptr1 the const char * returned by
  // function data(). NOTE: this is a potentially dangerous
  // assignment. If the string is modified, the pointer
  // ptr1 can become invalid.
  ptr1 = s.data();  
  cout << "\nptr1 is ";
  for ( int k = 0; k < len; ++k )
     cout << *(ptr1 + k);   // use pointer arithmetic

  cout << "\nptr2 is " << ptr2 << endl;
  delete [] ptr2;

  return 0;
}

/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
