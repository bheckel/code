//////////////////////////////////////////////////////////////////////////////
//     Name: templates.cpp
//
//  Summary: Demo of templates, C++'s implementation of parametric
//           polymorphism.  The type is a parameter of the code body.
//
//           Like macro but the compiler rather than the preprocessor expands
//           the template, replacing T's where needed.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 16)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

// T is the substitution parameter, in that it represents a type name. Also,
// you see T used everywhere in the class where you would normally see the
// specific type the container holds.
template<class T>
class Array {
  private:
    enum { size = 100 };
    T A[size];
  public:
    T& operator[](int index) {
      return A[index];
  }
};


int main() {
  // The compiler expands the Array template (this is called instantiation)
  // twice, to create two new generated classes, which you can think of as
  // Array_int and Array_float. 
  Array<int> ia;
  Array<float> fa;

  for ( int i = 0; i < 20; i++ ) {
    ia[i] = i * i;
    fa[i] = float(i) * 1.1;
  }

  for ( int j = 0; j < 20; j++ )
    cout << j << ": " << ia[j] << ", " << fa[j] << endl;
} 
