//////////////////////////////////////////////////////////////////////////////
//     Name: fn_ret_ptr.cpp
//
//  Summary: Demo of returning a string from a function using new.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus Stephen
//                                     Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

char * buildstr(char c, int n);

int main() {
  int times;
  char ch;

  cout << "Enter char: ";
  cin >> ch;
  cout << "Enter number of times: ";
  cin >> times;

  char *ps = buildstr(ch, times);
  cout << ps << endl;

  // TODO Actually deleting pstr, right?
  delete [] ps;  // burden of cleanup falls on the caller

  return 0;
}

char * buildstr(char c, int n) {
  char *pstr = new char[n+1];  // leave space for the null

  pstr[n] = '\0';

  // Fill in the array back to front.
  while ( n-- > 0 )
    pstr[n] = c;

  return pstr;
}
