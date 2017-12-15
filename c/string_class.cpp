// Modified: Tue 18 Feb 2003 21:21:33 (Bob Heckel)
// Fig. 8.5: string1.cpp
// Member function definitions for class String
#include <iostream>
using std::cout;
using std::endl;

#include <iomanip>
using std::setw;

#include <cstring>
#include <cassert>
#include "string_class.h"

// Convert char* to String.
String::String(const char *s) : length(strlen(s)) {
  cout << "Conversion constructor: " << s << '\n';
  setString(s);    // call utility function
}


String::String(const String &copy) : length(copy.length) {
  cout << "Copy constructor: " << copy.sPtr << '\n';
  setString(copy.sPtr);
}


// Destructor.
String::~String() {
  cout << "Destructor: " << sPtr << '\n';
  delete [] sPtr;         // reclaim string
}


// Overloaded = operator; avoids self assignment
const String &String::operator=(const String &right)
{
   cout << "operator= called\n";

   if ( &right != this) {         // avoid self assignment
      delete [] sPtr;              // prevents memory leak
      length = right.length;       // new String length
      setString(right.sPtr);     // call utility function
   }
   else
      cout << "Attempted assignment of a String to itself\n";

   return *this;   // enables cascaded assignments
}

// Concatenate right operand to this object and
// store in this object.
const String &String::operator+=(const String &right)
{
   char *tempPtr = sPtr;        // hold to be able to delete
   length += right.length;      // new String length
   sPtr = new char[ length + 1 ]; // create space
   assert(sPtr != 0);   // terminate if memory not allocated
   strcpy(sPtr, tempPtr);     // left part of new String
   strcat(sPtr, right.sPtr);  // right part of new String
   delete [] tempPtr;           // reclaim old space
   return *this;                // enables cascaded calls
}

// Is this String empty?
bool String::operator!() const { return length == 0; }

// Is this String equal to right String?
bool String::operator==(const String &right) const
   { return strcmp(sPtr, right.sPtr) == 0; }

// Is this String less than right String?
bool String::operator<(const String &right) const
   { return strcmp(sPtr, right.sPtr) < 0; }

// Return a reference to a character in a String as an lvalue.
char &String::operator[](int subscript)
{
   // First test for subscript out of range
   assert(subscript >= 0 && subscript < length);

   return sPtr[ subscript ];  // creates lvalue
}

// Return a reference to a character in a String as an rvalue.
const char &String::operator[](int subscript) const
{
   // First test for subscript out of range
   assert(subscript >= 0 && subscript < length);

   return sPtr[ subscript ];  // creates rvalue
}

// Return a substring beginning at index and
// of length subLength
String String::operator()(int index, int subLength)
{
   // ensure index is in range and substring length >= 0
   assert(index >= 0 && index < length && subLength >= 0);

   // determine length of substring
   int len;

   if ( ( subLength == 0 ) || ( index + subLength > length ) )
      len = length - index;
   else
      len = subLength;

   // allocate temporary array for substring and 
   // terminating null character
   char *tempPtr = new char[ len + 1 ];
   assert(tempPtr != 0); // ensure space allocated

   // copy substring into char array and terminate string
   strncpy(tempPtr, &sPtr[ index ], len);
   tempPtr[ len ] = '\0';

   // Create temporary String object containing the substring
   String tempString(tempPtr);
   delete [] tempPtr;  // delete the temporary array

   return tempString;  // return copy of the temporary String
}

// Return string length
int String::getLength() const { return length; }

// Utility function to be called by constructors and assignment operator.
void String::setString(const char* string2) {
  sPtr = new char[length + 1]; // allocate storage
  assert(sPtr != 0);  // terminate if memory not allocated
  strcpy(sPtr, string2);       // copy literal to object
}

// Overloaded output operator
ostream &operator<<(ostream &output, const String &s)
{
   output << s.sPtr;
   return output;   // enables cascading
}

// Overloaded input operator
istream &operator>>(istream &input, String &s)
{
   char temp[ 100 ];   // buffer to store input

   input >> setw(100) >> temp;
   s = temp;        // use String class assignment operator
   return input;    // enables cascading
}



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *                                                                        *
 * DISCLAIMER: The authors and publisher of this book have used their     *
 * best efforts in preparing the book. These efforts include the          *
 * development, research, and testing of the theories and programs        *
 * to determine their effectiveness. The authors and publisher make       *
 * no warranty of any kind, expressed or implied, with regard to these    *
 * programs or to the documentation contained in these books. The authors *
 * and publisher shall not be liable in any event for incidental or       *
 * consequential damages in connection with, or arising out of, the       *
 * furnishing, performance, or use of these programs.                     *
 *************************************************************************/
