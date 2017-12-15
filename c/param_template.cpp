//////////////////////////////////////////////////////////////////////////////
//     Name: param_template.cpp
//
//  Summary: Function templates and class templates can include other 
//           parameters that are constant values (instead of types).
//
//           Templates are only compiled on demand.  When an instantiation is
//           required, the compiler generates from the template a function
//           specifically for that type.
//
//           See also function_template.cpp or class_template.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.1)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

// Class to store arrays.
template <class T, int N>
class CMyarray {
  ///private:
    T memblock[N];
  public:
    void setmember(int x, T value);
    T getmember(int x);
};


template <class T, int N>
void CMyarray<T,N>::setmember(int x, T value) {
  memblock[x] = value;
}


template <class T, int N>
T CMyarray<T,N>::getmember(int x) {
  return memblock[x];
}


int main() {
  CMyarray<int,5> myints;
  CMyarray<float,5> myfloats;

  myints.setmember(0, 100);  // set element 0 to value 100
  myfloats.setmember(3.0, 3.1416);

  cout << myints.getmember(0) << '\n';
  cout << myfloats.getmember(3) << '\n';

  return 0;
}
