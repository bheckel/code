//: C02:Declare.cpp
// Declaration & definition examples
// Adapted: Fri 28 Sep 2001 16:24:37 (Bob Heckel -- Thinking in C++ Ch2)
//
// The declaration declares the interface. The definition is what it actually
// does. 
#include <stdio.h>

extern int i;          // variable declaration without definition
extern float f(float); // function declaration

float b;            // declaration & definition
float f(float a) {  // definition
  return a + 1.0;
}

int i;          // definition (declared above)
int h(int x) {  // declaration & definition
  return x + 1;
}

int main() {
  b = 1.0;
  printf("b is: %f\n", b);
  i = 2;
  printf("i is: %d\n", i);
  printf("fn f is: %f\n", f(b));
  printf("fn h is: %d\n", h(i));

  return 0;
}
