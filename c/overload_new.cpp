//////////////////////////////////////////////////////////////////////////////
//     Name: overload_new.cpp
//
//  Summary: Overload the new operator.  Good when you need to use a custom
//           routine to allocate memory.  Uses malloc (which the compiler
//           probably uses anyway).
//
//  Adapted: Mon 11 Aug 2003 19:48:11 (Bob Heckel -- Thinking in C++ Eckel
//                                     Ch. 13)
//////////////////////////////////////////////////////////////////////////////
#include <cstdio>
#include <cstdlib>
using namespace std;

// The first argument is always the size of the object, which is secretly
// calculated and passed by the compiler.
void* operator new(size_t sz) {
  printf("in operator new: %d Bytes\n", sz);

  void* m = malloc(sz);
  if ( !m ) 
    puts("out of memory");

  return m;
}

void operator delete(void* m) {
  puts("in operator delete");
  free(m);
}

class Dummy {
  int i[100];
public:
  Dummy() { puts("Dummy::Dummy()"); }
  ~Dummy() { puts("Dummy::~Dummy()"); }
};

int main() {
  puts("in main: creating & destroying an int");
  // Using an object of a built-in type for simplicity.
  int* p = new int(47);
  delete p;

  puts("\nin main: creating & destroying an s");
  Dummy* s = new Dummy;
  delete s;

  puts("\nin main: creating & destroying Dummy[3]");
  Dummy* da = new Dummy[3];
  delete []da;
} 
