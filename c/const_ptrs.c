//////////////////////////////////////////////////////////////////////////////
//     Name: construct_destruct.cpp
// 
//  Summary: Demo of using const pointers for args and return values.
//           
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++ Ch 8)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>

// TEST ARG VALUES----

// Takes normal, non-const ptr.
void t(int *ip) { 
  cout << "in t: " << *ip << "\n"; 
}


// Takes const ptr as argument.
void u(const int* cip) {
  ///*cip = 2; // illegal -- modifies value
  int i = *cip; // OK -- copies value
  ///int *ip2 = cip; // illegal: non-const
  cout << "in u: " << *cip << "\n"; 
}


// TEST RETURN VALUES----

// Returns a const char* that is created from a character array literal. 
const char *v() {
  cout << "in v\n";

  // Returns address of static character array:
  return "result of function v()";
}


// The return value of w() requires that both the pointer and what it points
// to must be const. 
const int *const w() {
  static int i;
  cout << "in w\n";

  return &i;
}


int main() {
  int        x   = 0;
  int       *ip  = &x;
  const int *cip = &x;

  t(ip);  // OK
  ///t(cip); // passing ptr-to-const is not OK

  u(ip);  // OK
  u(cip); // also OK

  ///char *cp = v(); // not OK
  const char *ccp = v(); // OK

  ///int *ip2 = w(); // not OK
  const int *const ccip = w(); // OK
  const int *cip2 = w(); // OK
  ///*w() = 1; // not OK
} 
