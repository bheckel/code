// Fig. 15.16: fig15_16.cpp
// Driver to test class Tree
// Modified: Sat 22 Mar 2003 20:42:05 (Bob Heckel)
#include <iostream>
#include <iomanip>
#include "Tree.h"

using std::cout;
using std::cin;
using std::setiosflags;
using std::ios;
using std::setprecision;

int main() {
  Tree<int> intTree;
  int intVal, i;

  cout << "Enter 10 integer values, follow each with <CR>:\n";
  for( i = 0; i < 10; i++ ) {
    cin >> intVal;
    intTree.insertNode(intVal);
  }

  cout << "\nPreorder traversal\n";
  intTree.preOrderTraversal();

  cout << "\nInorder traversal\n";
  intTree.inOrderTraversal();

  cout << "\nPostorder traversal\n";
  intTree.postOrderTraversal();


  // Identical but use doubles.
  Tree<double> doubleTree;
  double doubleVal;

  cout << "\n\n\nEnter 10 double values:\n"
       << setiosflags(ios::fixed | ios::showpoint)
       << setprecision(1);
  for ( i = 0; i < 10; i++ ) {
    cin >> doubleVal;
    doubleTree.insertNode(doubleVal);
  }

  cout << "\nPreorder traversal\n";
  doubleTree.preOrderTraversal();

  cout << "\nInorder traversal\n";
  doubleTree.inOrderTraversal();

  cout << "\nPostorder traversal\n";
  doubleTree.postOrderTraversal();

  return 0;
}


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
