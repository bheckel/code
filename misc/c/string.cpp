//: C02:HelloStrings.cpp
// The basics of the Standard C++ string class
#include <string>
#include <iostream>
using namespace std;

int main() {
  string s1, s2;               // empty strings
  string s3 = "Hello, World."; // initialized
  string s4("I am");           // also initialized

  s2 = "Today";                // assigning to a string
  s1 = s3 + " " + s4;          // combining strings
  s1 += " 42 ";                // appending to a string
  cout << s1 + s2 + "!" << endl;
}

