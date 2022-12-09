//////////////////////////////////////////////////////////////////////////////
//     Name: class_template.cpp
//
//  Summary: A class can have members based on generic types that do not need
//           to be defined at the moment of creating the class or whose
//           members use these generic types.
//
//           See also function_template.cpp
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.1)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>

////

// Store two elements of *any* valid type.
template <class T>
class CPair {
    T value1, value2;
  public:
    // Declaration and definition (TODO is this a constructor?)
    CPair(T first, T second) { value1=first; value2=second; }  
    // Declaration only.
    T getmax();
};


// Definition.  If we define a function member outside the declaration we
// always must also precede the definition with the prefix template <...> 
template <class T>
T CPair<T>::getmax() {
  T retval;
  retval = value1>value2 ? value1 : value2;

  return retval;
}

////


int main() {
  // Create new object (to store 2 ints in this case)
  // type:       object:
  CPair<int> myobject(100, 75);
  //^^^^^^^ ^^^^^^^^^^^^^^^^^
  cout << myobject.getmax();

  return 0;
}
