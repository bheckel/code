//////////////////////////////////////////////////////////////////////////////
//     Name: cp.cpp
//
//  Summary: Demo of copying a file.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <string>
#include <fstream>
using namespace std;

int main(void) {
  string s;

  // Create an ifstream object.
  ifstream in("junk1");   // open for reading
  // Create an ofstream object.
  ofstream out("junk2");  // open for writing

  // We can fill up a string object without knowing how much storage we're
  // going to need. 

  while ( getline(in, s) )  // discards newline char
    out << s << "\n";       // ... must add it back

  cout << "copied junk1 to junk2\n";
} 
