//////////////////////////////////////////////////////////////////////////////
//     Name: stack.cpp
//
//  Summary: Stack class demo using a stack of integers.
//
//  Adapted: Sun, 19 Nov 2000 13:20:10 (Bob Heckel -- Bartosz Milewski
//                                      tutorial)
//////////////////////////////////////////////////////////////////////////////

#include "stack.h"
#include <cassert>
#include <iostream>
using std::cout;
using std::endl;

//compile with NDEBUG=1 to get rid of assertions

// Define Push (already declared in stack.h).
// The name Push must be qualified since it is declared elsewhere.
void IStack::Push(int i) {
  assert(_top < maxStack);
  _arr[_top] = i;
  cout << "DEBUG>in Push _arr[_top] is " << _arr[_top] << "<DEBUG" << endl;
  ++_top;
}

int IStack::Pop() {
  assert(_top > 0);
  --_top;
  cout << "DEBUG>in Pop _arr[_top] is " << _arr[_top] << "<DEBUG" << endl;
  return _arr[_top];
}
 
int IStack::Top() {
  assert(_top > 0);
  return _arr[_top-1];
}
 
void CStack::Push(char ch) {
  assert(_top < maxStack);
  _arr[_top] = ch;
  cout << "CStack---in CStack Push(char ch), _arr[_top] is " 
                                                       << _arr[_top] << endl;
  ++_top;
}

char CStack::Pop() {
  assert(_top > 0);
  --_top;
  cout << "CStack------in CStack Pop(), _arr[_top] is " << _arr[_top] << endl;
}

// Used to loop over each char in the ch string.
int CStack::Counter() const {
  return _top;
}


void main(void) {
  IStack istackobj;

  // Stacks use LIFO.
  istackobj.Push(11);
  cout << "istackobj.Push(11) just pushed istackobj 11 onto top." << endl;

  istackobj.Push(22);
  cout << "Another Push() just occurred, so top is now: " << istackobj.Top() << endl;
  cout << "istackobj.Push(22) just pushed istackobj 22 onto top." << endl;

  istackobj.Push(33);
  cout << "Another Push() just occurred, so top is now: " << istackobj.Top() << endl;
  cout << "istackobj.Push(33) just pushed istackobj 33 onto top." << endl;

  cout << "Popped istackobj " << istackobj.Pop() << " from the top." << endl;
  cout << "Popped istackobj " << istackobj.Pop() << " from the top." << endl;
  cout << "Popped istackobj " << istackobj.Pop() << " from the top." << endl;

  // Death blow test.
  ///istackobj.Pop();

  CStack cstackobj;
  char *str;
  str = "dog";
 /// for ( int i=0; str[i]!='\0'; i++ ) {
  while ( *str != '\0' ) {
    /// cstackobj.Push(str[i]);
    cstackobj.Push(*str++);
  }
  while ( cstackobj.Counter() > 0 ) {
    cstackobj.Pop();
  }
}
