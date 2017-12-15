//////////////////////////////////////////////////////////////////////////////
//     Name: floatingpoint.cpp
//
//  Summary: Demo that float has less precision than double.
//
//  Adapted: Mon 22 Jul 2002 20:02:52 (Bob Heckel C++ Primer Plus 4th ed
//                                     Stephen Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

int main() {
  cout.setf(ios::fixed, ios::floatfield);  // force fixed point
  float tub = 10.0 / 3.0;
  double mint = 10.0 / 3.0;
  const float million = 1.0e6;

  cout << "tub is " << tub;
  // float is good to at least 6 digits of precision.
  cout << ", a million tubs is " << million * tub;
  cout << ", \nand ten million tubs is ";
  cout << 10 * million * tub << endl << endl;

  // double is good to at least 15 digits of precision.
  cout << "mint is " << mint << ", \nand a million mints is ";
  cout << million * mint << endl;

  return 0;
}
