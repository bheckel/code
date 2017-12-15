//////////////////////////////////////////////////////////////////////////////
//     Name: class_simple.cpp  (see class_simple.h)
//
//  Summary: Demo of using a basic, almost useless, class.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 14)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "class_simple.h"
using namespace std;


int main() {
  X an_X_obj;
  X another_X_obj;
  int num;

  num = an_X_obj.read();
  cout << "after constructor, before set: " << num << endl;

  an_X_obj.set(2);

  num = an_X_obj.read();
  cout << "after set(2): " << num << endl;

  num = an_X_obj.permute();
  cout << "after permute(): " << num << endl;

  num = another_X_obj.read();
  cout << endl << "meanwhile, another_X_obj is unaffected by all this: " 
                                                              << num << endl;
}
