//////////////////////////////////////////////////////////////////////////////
//     Name:  reference_vs_ptr.cpp
//
//  Summary:  Demo of using C++ references instead of pointers.
//
//            The major differences between a pointer and a reference are:
//
//            You must initialize a reference with the object it refers to. A
//            declaration such as
//
//            int &iref;
//
//            is meaningless (except as a function parameter). Once
//            initialized, you can't modify a reference to refer to a
//            different object. Since a reference always refers to something,
//            you don't need to check for NULL as you do with pointers.
//
//            References neither require nor allow the use of the & or *
//            operators. All addressing and dereferencing are automatic. You
//            can think of a reference as a const pointer that is derefenced
//            each time it is used.
//
//  Adapted: Mon 08 Jul 2002 16:38:31 (Bob Heckel -- Code Capsules 1993 Chuck
//                                     Allison)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <string>
#include <stdio.h>  // for printf()
using namespace std;


// Reference version:
int main(void) {
  int i     = 10;
  int &iref = i;  // an "alias" for i

  // No need to explicitly de-reference.
  printf("%d\n", iref);
  // Changing the alias changes the actual.
  iref = 20;
  printf("%d\n", i);

  return 0;
}


// C-style pointer version:
///int main(void) {
///  int i     = 10;
///  int *iref = &i;
///
///  printf("%d\n", *iref);
///  *iref = 20;
///  printf("%d\n", i);
///  return 0;
///}


// You should see:
// 10
// 20
