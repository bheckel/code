// Fig. 15.3: listnd.h
// ListNode template definition
#ifndef LISTND_H
#define LISTND_H

// Adapted: Sat Mar 15 12:01:33 2003 (Bob Heckel)

template<class NODETYPE> class List;  // forward declaration

template<class NODETYPE>
class ListNode {
   friend class List<NODETYPE>;
public:
   ListNode(const NODETYPE&);  // constructor
   NODETYPE getData() const;   // return data in the node
private:
   // Nodes always contain data and a pointer.
   NODETYPE data;                // data
   ListNode<NODETYPE>* nextPtr;  // ptr to next node in the list
};


// Constructor.
template<class NODETYPE>
ListNode<NODETYPE>::ListNode(const NODETYPE& info) : data(info), nextPtr(0) {}

// Return a copy of the data in the node.
template<class NODETYPE>
NODETYPE ListNode<NODETYPE>::getData() const { return data; }

#endif


/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
