//////////////////////////////////////////////////////////////////////////////
//     Name: function_template.cpp
//
//  Summary: Use a function template and call it with two different patterns. 
//
//           See also class_template.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.1)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Templates allow us to create generic functions that admit *any* data type
// as parameters and return a value without having to overload the function
// with all the possible data types.
// Function template:
template <class T>    // T is a generic data type
T GetMax(T a, T b) {
  T result;   // result is an object of type T (that is, whatever is in <> )

  result = (a > b) ? a : b;

  return(result);
}


// We can also make template-functions that admit more than one generic class
// or data type: 
///template <class T, class U>
///T GetMin(T a, U b) {
///    return(a<b?a:b);
///}
// In this case, our template function GetMin() admits two parameters of
// different types and returns an object of the same type as the first
// parameter (T) that is passed. For example, after that declaration we could
// call the function like so: 
///int i, j;
///long l;
///i = GetMin<int,long>(j, l);
///or, even though j and l are different types:
///i = GetMin(j, l);


int main() {
  int  i=5,  j=6, k;
  long l=10, m=5, n;

  // Now call GetMax() with two different patterns:

  // k is properly returned as an int b/c i is an int
  ///k = GetMax<int>(i, j);
  // ^               ^
  k = GetMax(i, j);   // the <int> is not required (compiler figures it out)

  ///n = GetMax<long>(l, m);
  n = GetMax(l, m);   // the <long> is not required (compiler figures it out)

  cout << k << endl;
  cout << n << endl;

  return 0;
}
