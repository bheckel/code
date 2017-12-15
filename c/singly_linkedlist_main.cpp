//////////////////////////////////////////////////////////////////////////////
//     Name: singly_linkedlist_main.cpp
//
//  Summary: Demo of a singly linked list.
//
//  Adapted: Sat 04 Jan 2003 11:49:13 (Bob Heckel -- C++ For C Programmers 
//                                     Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "singly_linkedlist.h"

int main() {
  slist* p;

  { // <---prove the destructor fires at block exit
    slist s;
    s.prepend('A');
    s.prepend('B');
    s.prepend('C');
    s.del();  // deletes 'C'
    s.prepend('D');
    s.print();
    p = &s;
    p->print();
    cout << "exiting inner block\n";
  }  // <---destructor is invoked here
  cout << "exiting outer block\n";

  slist t;
  slistelem* selm;
  t.prepend('E');
  t.prepend('F');
  selm = t.first();
  cout << "\nfirst elem of slist t is: " << selm->data << endl;
}
