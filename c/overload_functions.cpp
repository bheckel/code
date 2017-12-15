//////////////////////////////////////////////////////////////////////////////
//     Name: overload_functions.cpp
//
//  Summary: Overloaded functions.
//
//  Adapted: Sun 06 Jan 2002 13:22:40 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut2-3.html)
// Modified: Sun 28 Jul 2002 13:51:53 (Bob Heckel -- add more divide functions)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Integer division version.
int divide(int a, int b);

// Floating point division version.
float divide(float a, float b);

// Won't work, same signature as above, even though return type is different.
///char * divide(float a, float b);

// Return a pointer version.
char * divide();

// Manipulate an array directly version.  Doesn't have anything to do with
// division.
// TODO not working
///void divide(char * arr, int x, int y, int z);


int main(void) {
  int x=6, y=2;
  ///float n=6.0, m=2.0, q=42.0;
  float n=6.0, m=2.0;

  // Integer division.
  cout << divide(x,y);
  cout << "\n";

  // Floating point division.
  cout << divide(n,m);
  cout << "\n";

  // Return a pointer version.
  char * hold;
  hold = divide();
  cout << hold;
  cout << "\n";

  // Manipulate an array directly version.
  // TODO not working
  ///char * str = "a string";
  ///char str[] = "a string";
  ///cout << str;
  ///cout << "\n";
  ///division(str, 66, 67, 68);
  ///cout << str;
  ///cout << "\n";

  return 0;
}


// Integer division.
int divide(int a, int b) {
  cout << "I'm in the int version fn. ";

  return(a/b);
}


// Floating point division.
float divide(float a, float b) {
  return(a/b);
}


// Return a pointer version.
char * divide() {
  char * d;

  d = "no division performed";

  return d;
}


// TODO not working
// Manipulate an array version.
///void divide(char * arr, int x, int y, int z) {
  ///cout << x << "!!!!!" << endl;
  ///arr = "metamorphosis";
///}


///void divide(char strliteral) {
  ///strliteral = "a string literal";
///}
