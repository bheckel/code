//////////////////////////////////////////////////////////////////////////////
//     Name: minutes2hours.cpp
//
//  Summary: Demo of parsing minutes into hours and minutes.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus Stephen
//                                     Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

int main() {
  const int MINSPERHR = 60;
  int min1 = 40;
  int min2 = 30;
  int totmins;
  int hours = 1;
  int tothrs;

  totmins = (min1 + min2) % MINSPERHR;
  tothrs = hours + ((min1+min2) / MINSPERHR);

  cout << tothrs << " hours " << totmins << " mins" << endl;

  return 0;
}
