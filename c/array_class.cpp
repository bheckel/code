// Modified: Sun 16 Feb 2003 15:22:02 (Bob Heckel)
// Fig 8.4: array1.cpp
// Member function definitions for class Array
#include <iostream>
using std::cout;
using std::cin;
using std::endl;

#include <iomanip>
using std::setw;

#include <cstdlib>
#include <cassert>
#include "array_class.h"

// Initialize static data member at file scope.
int Array::arrayCount = 0;   // no objects yet

// Default constructor for class Array (default size 3).
Array::Array(int arraySize) {
   size = (arraySize > 0 ? arraySize : 3); 
   ptr = new int[size];   // create space for array
   assert(ptr != 0);      // terminate if memory not allocated
   ++arrayCount;          // count one more object

   for ( int i=0; i<size; i++ )
     ptr[i] = 0;          // initialize array with all zeros
}


// Copy constructor for class Array.  Must receive a reference to prevent
// infinite recursion.
Array::Array(const Array &init) : size(init.size) {
  ptr = new int[size];   // create space for array
  assert(ptr != 0);      // terminate if memory not allocated
  ++arrayCount;          // count one more object

  for ( int i = 0; i < size; i++ )
    ptr[i] = init.ptr[i];  // copy init into object
}


// Destructor for class Array.
Array::~Array() {
  delete [] ptr;            // reclaim space for array
  --arrayCount;             // one fewer objects
}


// Get the size of the array.  Probably s/b inline.
int Array::getSize() const { return size; }


// Overloaded assignment operator const return avoids: (a1 = a2) = a3
const Array& Array::operator=(const Array &right) {
  if ( &right != this ) {  // check for self-assignment
     // For arrays of different sizes, deallocate original left side array,
     // then allocate new left side array.
     if ( size != right.size ) {
       delete [] ptr;         // reclaim space
       size = right.size;     // resize this object
       ptr = new int[size];   // create space for array copy
       assert(ptr != 0);      // terminate if not allocated
     }

     for ( int i = 0; i < size; i++ )
       ptr[i] = right.ptr[i];  // copy array into object
  }

  return *this;   // enables x = y = z cascading
}


// Determine if two arrays are equal and return true, otherwise return false.
bool Array::operator==(const Array& right) const {
  if ( size != right.size )
    return false;    // arrays are of different sizes

  for ( int i = 0; i < size; i++ )
    if ( ptr[i] != right.ptr[i] )
      return false;   // the 2 array's contents are not equal

  return true;        // the 2 array's contents are equal
}


// Overloaded subscript operator for non-const Arrays reference return.  
// Creates an lvalue.
int& Array::operator[](int subscript) {
  // Check for subscript out of range error.
  assert((0 <= subscript) && (subscript < size));

  return ptr[subscript]; // reference return
}


// Overloaded subscript operator for const Arrays const reference return.
// Creates an rvalue.
const int& Array::operator[](int subscript) const {
  // Check for subscript out of range error.
  assert(0 <= subscript && subscript < size);

  return ptr[subscript]; // const reference return
}


// Return the number of Array objects instantiated.  Static functions cannot
// be const.
int Array::getArrayCount() { return arrayCount; }


// Overloaded input operator for class Array; inputs values for entire array.
istream& operator>>(istream& input, Array& a) {
  for ( int i=0; i<a.size; i++ )
    input >> a.ptr[i];

  return input;   // enables  cin >> x >> y;  cascading
}


// Overloaded output operator for class Array.
ostream& operator<<(ostream& output, const Array& a) {
  int i;

  for ( i = 0; i < a.size; i++ ) {
    output << setw(12) << a.ptr[ i ];

     if ( (i + 1) % 2 == 0 ) // 2 numbers per row of output
       output << endl;
  }

  if ( i % 4 != 0 )
    output << endl;

  return output;   // enables  cout << x << y;  cascading
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
