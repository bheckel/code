//////////////////////////////////////////////////////////////////////////////
//     Name: iterator.cpp
//
//  Summary: Demo of C++ iterators.
//
//  Adapted: Sat 30 Aug 2003 15:03:09 (Bob Heckel --
//           http://www.cs.brown.edu/people/jak/proglang/cpp/stltut/tut.html)
//////////////////////////////////////////////////////////////////////////////
#include <string.h>
#include <algo.h>
#include <vector.h>
#include <stdlib.h>
#include <iostream.h>
 
// This approach is much faster than using iterator-less qsort.
int main() {
  vector<int> v;   // create an empty vector of integers
  int input;

  while ( cin >> input )   // while not end of file
    v.push_back(input);    // append to vector v
 
  // sort takes two random iterators, and sorts the elements between
  // them.  As is always the case in STL, this includes the value
  // referred to by first but not the one referred to by last; indeed,
  // this is often the past-the-end value, and is therefore not
  // dereferenceable.
  sort(v.begin(), v.end());
 
  int n = v.size();

  for ( int i = 0; i < n; i++ )
    cout << v[i] << " ";
}
