//////////////////////////////////////////////////////////////////////////////
//     Name: specialized_template.cpp
//
//  Summary: A template specialization allows a template to make specific
//           implementations when the pattern is of a particular type.
//
//           See also class_template.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.1)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Generic template.
// We want domodulus() to work only when the type is <int>.  For any other
// type we want this function to return 0.
template <class T>
class CPair {
  public:
    CPair(T first, T second) { value1=first; value2=second; }
    T domodulus() { return 0; }
  private:
    T value1, value2;
};


// Specialized template.
// The specialization is part of a template.  For that reason we must begin
// the declaration with 'template <>'.  And indeed because it is a
// specialization for a concrete type, the generic type cannot be used in it
// and the first angle-brackets <> must appear empty. After the class name we
// must include the type that is being specialized enclosed between
// angle-brackets, i.e. <int> 
template <>
class CPair<int> {
  public:
    // Must define constructor just like the one above b/c no member is
    // inherited from the generic template to the specialized one.
    CPair(int first, int second) { value1=first; value2=second; }
    int domodulus();
  private:
    int value1, value2;
};


int CPair<int>::domodulus() {
  return(value1 % value2);
}


int main() {
  CPair<int> myints(100, 75);
  CPair<float> myfloats(100.0, 75.0);

  cout << myints.domodulus() << '\n';
  cout << myfloats.domodulus() << " ints only, sorry\n";

  return 0;
}
