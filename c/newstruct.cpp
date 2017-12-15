//////////////////////////////////////////////////////////////////////////////
//     Name: newstruct.cpp
//
//  Summary: Demo of using new to allocate struct memory.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus Stephen
//                                     Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

int main() {
  struct fish {
    char kind[20];
    int weight;
    float length;
  };

  fish * pole = new fish;

  cout << "Enter kind of fish" << endl;

  cin >> pole->kind;

  cout << "caught " << pole->kind << endl;

  return 0;
}
