// Fig. 19.5: fig19_05.cpp
// Demonstrating functions related to size and capacity
// Modified: Fri 04 Apr 2003 21:40:44 (Bob Heckel)
#include <iostream>

using std::cout;
using std::endl;
using std::cin;

#include <string>

using std::string;

void printStats(const string&);


int main() {
  string s;

  cout << "Stats before any input:\n";
  printStats(s);

  cout << "\n\nEnter a string: ";
  cin >> s;  // delimited by whitespace
  cout << "The string entered was: " << s;

  cout << "\nStats after input:\n";
  printStats(s);

  s.resize(s.length() + 10);
  cout << "\n\nStats after resizing by (length + 10):\n";
  printStats(s);

  cout << endl;

  return 0;
}


void printStats(const string& str) {
  cout << "capacity: " << str.capacity() 
       << "\nmax size: " << str.max_size()
       << "\nsize: " << str.size()
       << "\nlength: " << str.length()
       << "\nempty: " << (str.empty() ? "true": "false");             
}

/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
