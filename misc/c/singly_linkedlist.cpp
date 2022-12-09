//////////////////////////////////////////////////////////////////////////////
//     Name: singly_linkedlist.cpp
//
//  Summary: Demo of a singly linked list.
//
//           Compile e.g.
//           $ g++ -c singly_linkedlist.cpp
//           $ g++ singly_linkedlist.o singly_linkedlist_main.cpp
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include <cassert>
#include <iostream>
#include "singly_linkedlist.h"

// "push"
void slist::prepend(char c) {
  slistelem* temp = new slistelem;  // create element from free store
  assert(temp != 0);
  temp->next = h;  // link to slist
  temp->data = c;  // update head of slist
  h = temp;
}


// "pop"
void slist::del() {
  slistelem* temp = h;
  h = h->next;  // assumes a nonempty slist
  delete temp;
}


void slist::print() const {
  slistelem* temp = h;
  while ( temp != 0 ) {
    cout << temp->data << " --> ";
    temp = temp->next;
  }
  cout << "\n###" << endl;
}


// Release all list elements back to free store.
void slist::release() {
  // Original value of pointer intentionally not preserved.
  while ( h != 0 )
    del();  // release a list element back to free store
}


// Saying  delete h;  in the destructor would only delete the 1st elem of the
// list, so must do it via release().
slist::~slist() {
  cout << "destructor invoked\n";
  release();
}
