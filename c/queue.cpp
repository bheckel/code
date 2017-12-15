//////////////////////////////////////////////////////////////////////////////
//     Name: queue.cpp
//
//  Summary: Demo of a class that creates a queue.  Used by the Automated
//           Teller Machine simulation.
//
//  Adapted: Sun 11 Aug 2002 09:45:24 (Bob Heckel -- C++ Primer v4 Plus 
//                                     Stephen Prata)
//////////////////////////////////////////////////////////////////////////////
#include "queue.h"
#include <cstdlib>     // for rand()
using namespace std;

// Queue methods:
Queue::Queue(int qs) : qsize(qs) {
  front = rear = NULL;
  items = 0;
}

Queue::~Queue() {
  Node * temp;

  while ( front != NULL ) {  // while queue is not yet empty
    temp = front;            // save address of front item
    front = front->next;     // reset pointer to next item
    delete temp;
  }
}


bool Queue::isempty() const {
  return items == 0;
}


bool Queue::isfull() const {
  return items == qsize;
}


bool Queue::queuecount() const {
  return items;
}


// Add item to queue.
bool Queue::enqueue(const Item & item) {
  if ( isfull() )
    return false;

  Node * add = new Node;
  if ( add == NULL )     // quit if none available
    return false;

  add->item = item;      // set node pointers
  add->next = NULL;

  items++;

  if ( front == NULL )     // if queue is empty
    front = add;           // place item at front
  else
    rear->next = add;      // else place at rear

  rear = add;              // have rear point to new node

  return true;
}


// Place front item into item variable and remove from queue.
bool Queue::dequeue(Item & item) {
  if ( front == NULL )
    return false;

  item = front->item;   // set item to first item in queue
  items--;
  Node * temp = front;  // save location of first item
  front = front->next;  // reset front to next item
  delete temp;          // delete former first item
  if ( items == 0 )
    rear = NULL;

  return true;
}


// Customer method
// when -- time cust arrives
// The arrival time is set to when and processing time is set to a random
// value in the range 1-3.
void Customer::set(long when) {
  processtime = rand() & 3 + 1;
  arrive = when;
}
