// Fig. 15.16: tree.h
// Definition of template class Tree
// Modified: Sat 22 Mar 2003 20:45:53 (Bob Heckel)
#ifndef TREE_H
#define TREE_H

#include <iostream>
#include <cassert>
#include "treenode.h"

using std::endl;

template<class NODETYPE>
class Tree {
public:
  Tree();
  void insertNode(const NODETYPE&);
  void preOrderTraversal() const;
  void inOrderTraversal() const;
  void postOrderTraversal() const;
private:
  TreeNode<NODETYPE>* rootPtr;
  // Utility functions:
  void insertNodeHelper(TreeNode<NODETYPE>**, const NODETYPE&);
  void preOrderHelper(TreeNode<NODETYPE>*) const;
  void inOrderHelper(TreeNode<NODETYPE>*) const;
  void postOrderHelper(TreeNode<NODETYPE>*) const;
};


template<class NODETYPE>
Tree<NODETYPE>::Tree() { 
  rootPtr = 0; 
}


// TODO why not just call insertNodeHelper directly?
template<class NODETYPE>
void Tree<NODETYPE>::insertNode(const NODETYPE& value) { 
  insertNodeHelper(&rootPtr, value); 
}


// This function receives a pointer to a pointer so the pointer can be
// modified.
template<class NODETYPE>
void Tree<NODETYPE>::insertNodeHelper( 
                        TreeNode<NODETYPE>** ptr, const NODETYPE& value ) {
  if ( *ptr == 0 ) {   // tree is empty
     *ptr = new TreeNode<NODETYPE>(value);
     assert(*ptr != 0);
   }
   else                // tree is not empty
     if ( value < (*ptr)->data )
       insertNodeHelper( &( (*ptr)->leftPtr ), value );
     else
       if ( value > (*ptr)->data )
         insertNodeHelper( &( (*ptr)->rightPtr ), value );
       else
         cout << value << " invalid -- this is a dup" << endl;
}


///////preorder
template<class NODETYPE> 
void Tree<NODETYPE>::preOrderTraversal() const { 
  preOrderHelper(rootPtr); 
}


template<class NODETYPE>
void Tree<NODETYPE>::preOrderHelper(TreeNode<NODETYPE>* ptr) const {
  if ( ptr != 0 ) {
    cout << ptr->data << ' ';
    preOrderHelper(ptr->leftPtr);
    preOrderHelper(ptr->rightPtr);
  }
}
///////preorder


///////inorder
template<class NODETYPE>
void Tree<NODETYPE>::inOrderTraversal() const { 
  inOrderHelper(rootPtr); 
}


template<class NODETYPE>
void Tree<NODETYPE>::inOrderHelper(TreeNode<NODETYPE>* ptr) const {
   if ( ptr != 0 ) {
     inOrderHelper(ptr->leftPtr);
     cout << ptr->data << ' ';
     inOrderHelper(ptr->rightPtr);
   }
}
///////inorder


///////postorder
template<class NODETYPE>
void Tree<NODETYPE>::postOrderTraversal() const { 
  postOrderHelper(rootPtr); 
}


template<class NODETYPE>
void Tree<NODETYPE>::postOrderHelper(TreeNode<NODETYPE>* ptr) const {
  if ( ptr != 0 ) {
    postOrderHelper(ptr->leftPtr);
    postOrderHelper(ptr->rightPtr);
    cout << ptr->data << ' ';
  }
}
///////postorder

#endif


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *                                                                        *
 * DISCLAIMER: The authors and publisher of this book have used their     *
 * best efforts in preparing the book. These efforts include the          *
 * development, research, and testing of the theories and programs        *
 * to determine their effectiveness. The authors and publisher make       *
 * no warranty of any kind, expressed or implied, with regard to these    *
 * programs or to the documentation contained in these books. The authors *
 * and publisher shall not be liable in any event for incidental or       *
 * consequential damages in connection with, or arising out of, the       *
 * furnishing, performance, or use of these programs.                     *
 *************************************************************************/
