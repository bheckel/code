// Fig. 15.16: treenode.h
// Definition of class TreeNode
// Modified: Sat 22 Mar 2003 20:45:53 (Bob Heckel)
#ifndef TREENODE_H
#define TREENODE_H

template<class NODETYPE> class Tree;  // forward declaration

template<class NODETYPE>
class TreeNode {
  friend class Tree<NODETYPE>;
public:
   TreeNode(const NODETYPE& d) : leftPtr(0), data(d), rightPtr(0) {}
   NODETYPE getData() const { return data; }
private:
   NODETYPE data;
   TreeNode<NODETYPE>* leftPtr;  // pointer to left subtree
   TreeNode<NODETYPE>* rightPtr; // pointer to right subtree
};

#endif


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
