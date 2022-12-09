//////////////////////////////////////////////////////////////////////////////
//     Name: template_vect.cpp
//
//  Summary: Template-based vector type.
//
//  Adapted: Fri 10 Jan 2003 22:53:43 (Bob Heckel -- p. 249 C++ for C
//                                     Programmers Ira Pohl)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <cassert>

template <class T>
class myvector {
  private:
    T* p;                            // base pointer
    int size;                        // num of elements
  public:
    typedef T* iterator;
    explicit myvector(int n=10);     // create an n sized array
    myvector(const myvector<T>& v);  // copy vector
    myvector(const T a[], int n);    // copy an array into a vector
    ~myvector() { delete []p; }
    iterator begin() { return p; }
    iterator end() { return p+size; }
    T& operator[](int i);            // range-checked element
    myvector<T>& operator=(const myvector<T>& v);
};


// TODO why can't I separate the member definitions into template_vect.h ?
// namespaces??
// Default constructor.
template <class T>
myvector<T>::myvector(int n = 10) : size (n) {
  assert(n > 0);
  p = new T[size];
  assert(p != 0);
}


template <class T>
myvector<T>::myvector(const myvector<T>& v) {
  size = v.size;
  p = new T[size];
  assert(p != 0);
  for ( int i=0; i<size; ++i )
    p[i] = v.p[i];
}


template <class T>
myvector<T>::myvector(const T a[], int n) {
  assert(n > 0);
  size = n;
  p = new T[size];
  assert(p =! 0);
  for ( int i=0; i<size; ++i )
    p[i] = a[i];
}


// Return type is reference to T since this is an alias for the item stored in
// the container.  Using this return type allows the bracket operator to
// access the item in the container as an lvalue.
// With operator[] overloaded, we can access vectors as if they were native
// C++ arrays.
template <class T>
T& myvector<T>::operator[](int i) {
  assert(i>=0 && i<size);

  return p[i];
}


template <class T>
myvector<T>& myvector<T>::operator=(const myvector<T>& v) {
  assert(v.size == size);
  for ( int i=0; i<size; ++i )
    p[i] = v.p[i];

  return *this;
}


// TODO why can't I separate the rest of this file into template_vect_main.cpp
// and compile with a .o ? namespaces ??
// Client code is almost as simple as nonparameterized declarations.  Simply
// add within angle brackets the specific type that instantialtes the
// template (e.g. int or user-defined type).
int main() {
  myvector<double> v(5);
  myvector<double>::iterator itptr;
  myvector<int> v2(3);
  myvector<int>::iterator itptr2;

  int i, j;

  i = j = 0;

  for ( itptr=v.begin(); itptr!=v.end(); ++itptr )
    *itptr = 1.5 + i++;

  do {
    --itptr;
    cout << *itptr << " , ";
  } while ( itptr != v.begin() );

  for ( itptr2=v2.begin(); itptr2!=v2.end(); ++itptr2 )
    *itptr2 = 2 + j++;

  do {
    --itptr2;
    cout << *itptr2 << " , ";
  } while ( itptr2 != v2.begin() );

  cout << endl;
}
