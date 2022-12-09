//////////////////////////////////////////////////////////////////////////////
//     Name: void.cpp
// 
//  Summary: Demo of void pointers.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <cstdio>
#include <iostream>

int main() {
  void  *vp;
  // Simultaneous definition & initialization.
  char   c = 'a';
  int    i = 42;
  float  f = 42.1;
  double d = 43.1;

  // The address of ANY type can be assigned to a void pointer but once you
  // assign to a void* you lose any information about what type it is.  It
  // cannot be dereferenced directly (can't use * on it) because its length is
  // undetermined.  This means that before you can use the pointer, you must
  // cast it to the correct type:
  vp = &c;
  //                                   dereference
  //                                   _____________
  printf("char using printf is: %c\n", *((char*)vp));
  //                                     ^^^^^^^
  //                                      cast
  cout << "char using cout is: " << *((char*)vp) << endl;

  vp = &i;
  cout << "int using cout is: " << *((int*)vp) << endl;

  vp = &f;
  cout << "float using cout is: " << *((float*)vp) << endl;

  vp = &d;
  cout << "double using cout is: " << *((double*)vp) << endl;

  return 0;
} 
