//////////////////////////////////////////////////////////////////////////////
//     Name: new.cpp
//
//  Summary: Demo of using new to allocate memory at runtime.
//
//  Adapted: Sat 27 Jul 2002 11:52:56 (Bob Heckel -- C++ Primer Plus v4
//                                     Stephen Prata)
//  Modified: Sat 23 Nov 2002 17:50:21 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;


int main() {
  // iptr will be the only way to access the space you will be given.
  int* iptr;
  iptr = new int;    // allocate space for an int
  ///int* iptr = new int;    // allocate space for an int
  
  // *iptr holds garbage at this point in time.
  
  *iptr = 100;             // store a value in the newly created data object

  cout << "*iptr (val): " << *iptr << endl << "iptr (addr): " << iptr << endl;
  cout << "sizeof iptr the pointer: " << sizeof iptr << endl;
  cout << "sizeof iptr the value: " << sizeof *iptr << endl << endl;

  double * dptr = new double;
  *dptr = 100.0;
  // Proves that a pointer is always stored in 4 bytes (on this system) while
  // the value it points to will need the size of the type that the pointer
  // points to.
  cout << "*dptr (val): " << *dptr << endl << "dptr (addr): " << dptr << endl;
  cout << "sizeof dptr the pointer: " << sizeof dptr << endl;
  cout << "sizeof dptr the value: " << sizeof *dptr << endl << endl;

  delete dptr;
  // Compiler will reuse the iptr address if you delete iptr before declaring
  // dptr which is fine except for this pedantic demo.
  delete iptr; 

  return 0;
}
