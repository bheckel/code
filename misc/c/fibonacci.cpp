//////////////////////////////////////////////////////////////////////////////
//     Name: fibonacci.cpp
//
//  Summary: Demo of a push-down stack.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 16)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

class IntStack {
  private:
    enum { ssize = 100 };
    // For simplicity, the stack has been created here with a fixed size, but
    // you can also modify it to automatically expand by allocating memory off
    // the heap.  TODO how??
    int stack[ssize];
    int top;
  public:
    ///IntStack() : top(0) {}
    IntStack() : top() { top = 0; }  // clearer to me, should mean same thing
    void push(int i) { stack[top++] = i; }
    int pop() { return stack[--top]; }
};


int fibonacci(int n) {
  const int sz = 100;
  static int f[sz];   // compiler always initializes static arrays to zero

  f[0] = f[1] = 1;
  // Scan for unfilled array elements:
  int i;
  for ( i = 0; i < sz; i++ )
    if ( f[i] == 0 ) break;

  while ( i <= n ) {
    f[i] = f[i-1] + f[i-2];
    i++;
  }

  return f[n];
} 


int main() {
  IntStack is;

  // Add some Fibonacci numbers.
  for ( int i = 0; i < 20; i++ )
    is.push(fibonacci(i));

  for ( int k = 0; k < 20; k++ )
    cout << is.pop() << endl;
}
