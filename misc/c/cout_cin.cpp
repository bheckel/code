//////////////////////////////////////////////////////////////////////////////
//     Name: cout_cin.cpp
//
//  Summary: Demo of cout and cin
//
//           << is stream insertion operator (cout)
//           >> is stream extraction operator (cin)
//
//  Adapted: Thu 04 Oct 2001 22:54:43 (Bob Heckel -- 
//                        C02:Stream2.cpp From Thinking in C++, 2nd Edition)
// Modified: Sun 09 Feb 2003 11:38:10 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <iomanip>  // for setbase() (parameterized stream manipulators)
#include <cstdio>   // for printf()
#include <cassert>
using namespace std;

int main() {  // don't need void argument in C++
  int number = 14;

  // Part 1
  // Specifying formats with manipulators:
  cout << "a number in decimal: " << dec << 15 << endl;

  ///cout << "in octal: " << oct << 15 << endl;
  // Same
  cout << "in octal: " << setbase(8) << 15 << endl;

  cout << "in hex: " << hex << 15 << endl;

  cout << "non-printing char (linefeed): " << char(10) << endl;

  cout << "a floating-point number: " << 3.14159 << endl;

  cout << "non-printing char (linefeed): " << char(0xA) << endl;

  cout << "This is far too long to put on a "
          "single line\nbut it can be broken up with "
          "no ill effects\nas long as there is no "
          "punctuation separating\nadjacent character "
          "arrays.\n";

  cout << endl << "Enter a decimal number (core dump on 0): ";
  cin >> number;
  assert(number != 0);
  cout << "value in octal = 0" << oct << number << endl;

  printf("\n\nFYI printf still works in C++: %d\n", 42);

  // Part 2
  int anothernum, highestnum = -1;
  cout << "Enter num (EOF to end): ";
  while ( cin >> anothernum ) {
    if ( anothernum > highestnum )
      highestnum = anothernum;
    
    cout << "Enter num (EOF to end): ";
  }
  // Must reset stream base using the stream manipulator 'decimal'.  It was
  // changed to hex in Part 1.
  cout << "Highest is: " << dec << highestnum << endl;

  return 0;
}
