//////////////////////////////////////////////////////////////////////////////
//     Name: malloc.cpp
//
//  Summary: Malloc with class objects.  What you'd have to do if not for 
//           new()
//
//  Adapted: Sun 10 Aug 2003 20:52:42 (Bob Heckel Thinking in C++ Ch 13)
//////////////////////////////////////////////////////////////////////////////

//: C13:MallocClass.cpp
#include <cstdlib> // malloc() & free()
#include <cstring> // memset()
#include <iostream>
using namespace std;

class Obj {
  int i, j, k;
  enum { sz = 100 };
  char buf[sz];
public:
  void initialize() { // can't use constructor
    cout << "initializing Obj" << endl;
    i = j = k = 0;
    memset(buf, 0, sz);
  }
  void destroy() const { // can't use destructor
    cout << "destroying Obj" << endl;
  }
};

int main() {
  Obj* obj = (Obj*)malloc(sizeof(Obj));
  obj->initialize();
  // ... sometime later:
  obj->destroy();
  free(obj);
}
