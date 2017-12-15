//////////////////////////////////////////////////////////////////////////////
//     Name: timeclass.cpp
// 
//  Summary: Implementation of time functions (see timeclass.h).
//           
//  Adapted: Wed 24 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++ Ch 8)
//////////////////////////////////////////////////////////////////////////////

// Testing a simple time class
#include "test.h"
#include <iostream>
#include <unistd.h>
using namespace std;

int main() {
  Time start;
  sleep(3);
  Time end;

  cout << endl;
  cout << "start = " << start.ascii();
  cout << "end = " << end.ascii();
  cout << "delta = " << end.delta(&start);
  cout << "yrs since 1900 = " << end.since1900();
  cout << endl;
} 
