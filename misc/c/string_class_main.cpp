// Modified: Tue 18 Feb 2003 20:54:48 (Bob Heckel)
// Fig. 8.5: fig08_05.cpp
// Driver for class String
#include <iostream>

using std::cout;
using std::endl;

#include "string_class.h"

int main() {
  String s1("happy"), s2(" birthday"), s3;

  // Test overloaded equality and relational operators.
  cout << "s1 is \"" << s1 << "\"; s2 is \"" << s2
       << "\"; s3 is \"" << s3 << '\"' 
       << "\nThe results of comparing s2 and s1:"
       << "\ns2 == s1 yields " 
       << (s2 == s1 ? "true" : "false")
       << "\ns2 != s1 yields " 
       << (s2 != s1 ? "true" : "false")
       << "\ns2 >  s1 yields " 
       << (s2 > s1 ? "true" : "false") 
       << "\ns2 <  s1 yields " 
       << (s2 < s1 ? "true" : "false") 
       << "\ns2 >= s1 yields "
       << (s2 >= s1 ? "true" : "false")
       << "\ns2 <= s1 yields " 
       << (s2 <= s1 ? "true" : "false");

  // Test overloaded String empty (!) operator.
  cout << "\n\nTesting !s3:\n";
  if ( !s3 ) {
     cout << "s3 is empty; assigning s1 to s3;\n";
     s3 = s1;              // test overloaded assignment
     cout << "s3 is \"" << s3 << "\"";
  }

  // Test overloaded String concatenation operator.
  cout << "\n\ns1 += s2 yields s1 = ";
  s1 += s2;                // test overloaded concatenation
  cout << s1;

  // Test conversion constructor.
  cout << "\n\ns1 += \" to you\" yields\n";
  s1 += " to you";         // test conversion constructor
  cout << "s1 = " << s1 << "\n\n";

  // Test overloaded function call operator () for substring.
  cout << "The substring of s1 starting at\n"
       << "location 0 for 14 characters, s1(0, 14), is:\n"
       << s1(0, 14) << "\n\n";

  // Test substring "to-end-of-String" option.
  cout << "The substring of s1 starting at\n"
       << "location 15, s1(15, 0), is: "
       << s1(15, 0) << "\n\n";  // 0 is "to end of string"

  // Test copy constructor.
  String *s4Ptr = new String(s1);  
  cout << "*s4Ptr = " << *s4Ptr << "\n\n";

  // Test assignment (=) operator with self-assignment.
  cout << "assigning *s4Ptr to *s4Ptr\n";
  *s4Ptr = *s4Ptr;          // test overloaded assignment
  cout << "*s4Ptr = " << *s4Ptr << '\n';

  // Test destructor.
  delete s4Ptr;     

  // Test using subscript operator to create lvalue.
  s1[0] = 'C';      
  s1[1] = 'r';      
  s1[6] = 'B';
  cout << "\ns1 after s1[0] = 'H' and s1[6] = 'B' is: "
       << s1 << "\n\n";

  // Test subscript out of range.
  ///cout << "Attempt to assign 'd' to s1[30] yields:" << endl;
  ///s1[30] = 'd';     // ERROR: subscript out of range

  return 0;
}



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
