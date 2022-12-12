//////////////////////////////////////////////////////////////////////////////
//     Name: vector.cpp
//
//  Summary: Creating a vector (a container) that holds integers.  Vectors are
//           best for random-access and insertions at the end.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
// Modified: Sat 15 Feb 2003 11:29:13 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <vector>
using namespace std;

int main(void) {
  vector<int> v;   // vector template, creating a 'vector of ints'

  cout << v.size() << " and " << v.capacity() << "\n\n";

  for ( int i=0; i<10; i++ )
    v.push_back(i);

  cout << v.size() << " and " << v.capacity() << "\n\n";

  // Force an allocation to double capacity (use resize() if this is not what
  // you want).
  for ( int i=11; i<18; i++ )
    v.push_back(i);

  cout << v.size() << " and " << v.capacity() << "\n\n";

  for ( int i=0; i<v.size(); i++ )
    cout << v[i] << ", ";

  cout << endl;

  for ( int i=0; i<v.size(); i++ )
    // You also have the ability to assign (and thus to change) to any element
    // of a vector, also through the use of the square-brackets indexing
    // operator. 
    v[i] = v[i] * 10; // assignment  

  for ( int i=0; i<v.size(); i++ )
    cout << v[i] << ", ";

  cout << endl;
} 
