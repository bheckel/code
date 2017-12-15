//////////////////////////////////////////////////////////////////////////////
//     Name: newarray.cpp
//
//  Summary: Demo of using new to allocate array memory.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus Stephen
//                                     Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <string>
using namespace std;

int main() {
  double * p3 = new double [3]; // ask for space to hold 3 doubles at runtime
  
  p3[0] = 0.2;
  p3[1] = 0.5;
  p3[2] = 0.8;

  cout << "p3[1] is " << p3[1] << endl;

  p3++;  // pointer arithmetic is ok for pointers, wrong for array names

  cout << "Now p3[0] is " << p3[0] << endl;
  cout << "and p3[1] is " << p3[1] << endl;

  p3--;   // let delete use the right address

  cout << "And now p3[0] is back to " << p3[0] << endl;
  cout << "and p3[1] is back to " << p3[1] << endl;

  delete [] p3;

  return 0;
}
