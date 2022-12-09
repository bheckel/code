//////////////////////////////////////////////////////////////////////////////
//     Name: recursion.cpp
// 
//  Summary: Simple demonstration of recursion.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

void removeHat(char cat) {
  for(char c = 'A'; c < cat; c++)
    cout << "  ";

  if(cat <= 'Z') {
    cout << "cat " << cat << endl;

    removeHat(cat + 1); // Recursive call
  } else
    cout << "VOOM!!!" << endl;
}


int main() {
  removeHat('A');
} 
