// Fig. 8.5: string1.h
// Definition of a String class
#ifndef STRING1_H
#define STRING1_H

#include <iostream>

using std::ostream;
using std::istream;

class String {
  friend ostream& operator<<(ostream&, const String&);
  friend istream& operator>>(istream&, String&);

public:
  String(const char* = "(empty)");    // conversion/default ctor
  String(const String&);      // copy constructor
  ~String();
  const String& operator=(const String&);  // assignment
  const String& operator+=(const String&); // concatenation
  bool operator!() const;                  // is String empty?
  bool operator==(const String&) const; // test s1 == s2
  bool operator<(const String&) const;  // test s1 < s2

  // Test s1 != s2.
  bool operator!=(const String& right) const { 
    return !(*this == right); 
  }

  // Test s1 > s2.
  bool operator>(const String& right) const { 
    return right < *this; 
  }

  // Test s1 <= s2.
  bool operator<=(const String& right) const { 
    return !(right < *this); 
  }

  // Test s1 >= s2.
  bool operator>=(const String& right) const { 
    return !(*this < right); 
  }

  char& operator[](int);             // subscript operator
  const char& operator[](int) const; // subscript operator
  String operator()(int, int);       // return a substring
  int getLength() const;             // return string length

private:
  int length;   // string length 
  char* sPtr;   // pointer to start of string

  void setString(const char*);  // utility function
};

#endif



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
