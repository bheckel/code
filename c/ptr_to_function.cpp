//////////////////////////////////////////////////////////////////////////////
//     Name: ptr_to_function.cpp
//
//  Summary: Pointer to functions.
//
//  Adapted: Mon 07 Jan 2002 17:31:16 (Bob Heckel -- C++ Resources Network)
// Modified: Sun 28 Jul 2002 10:44:00 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

int addition (int a, int b) { 
  return(a+b); 
}


int subtraction (int a, int b) { 
  return(a-b); 
}


int operation(int x, int y, int (*functocall)(int,int)){
  int the_otherfn_result;

  the_otherfn_result = (*functocall)(x, y);

  return(the_otherfn_result);
}


int main(void) {
  int m, n;
  // minus is a pointer to a function that has two parameters of type
  // int, this one is immediately assigned to point to the function
  // subtraction, all in a single line:
  //
  int (*minus)(int,int) = subtraction;
  // This more verbose two step approach would also work.
  ///int (*minus)(int,int);
  ///minus = subtraction;

  n = operation(20, 11, minus);

  m = operation(7, 5, &addition);

  cout << n << " " << m << std::endl;

  return 0;
}
