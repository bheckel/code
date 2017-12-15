// Fig. 15.3: fig15_03.cpp
// List class test

// Probably should have called this linked_list_main.cpp

// Use a linked list instead of an array when:
//   1.  The number of data elements is unpredictable.
//   2.  The list needs to be sorted.

// Adapted: Sat Mar 15 11:59:51 2003 (Bob Heckel)

#include <iostream>
#include "list1.h"

using std::cin;
using std::endl;

// Function to test an integer List.
template<class T>
void testList(List<T>& listObject, const char* type) {
  cout << "Testing a List of " << type << " values\n";

  instructions();
  int choice;
  T value;

  do {
    cout << "? ";
    cin >> choice;

    switch ( choice ) {
       case 1:
         cout << "Enter " << type << ": ";
         cin >> value;
         listObject.insertAtFront(value);
         listObject.print();
         break;
       case 2:
         cout << "Enter " << type << ": ";
         cin >> value;
         listObject.insertAtBack(value);
         listObject.print();
         break;
       case 3:
         if ( listObject.removeFromFront(value) )
            cout << value << " removed from list\n";

         listObject.print();
         break;
       case 4:
         if ( listObject.removeFromBack(value) )
            cout << value << " removed from list\n";

         listObject.print();
         break;
     }
  } while ( choice != 5 );

  cout << "End list test\n\n";
}


void instructions() {
  cout << "Enter one of the following:\n"
       << "  1 to insert at beginning of list\n" 
       << "  2 to insert at end of list\n" 
       << "  3 to delete from beginning of list\n" 
       << "  4 to delete from end of list\n" 
       << "  5 to end list processing\n";
}


int main() {
  // Use templates to do an int version and a double version.

  List<int> integerList;
  cout << "Test #1 of 2:\n";
  testList(integerList, "integer");

  List<double> doubleList;
  cout << "Test #2 of 2:\n";
  testList(doubleList, "double");

  return 0;
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
