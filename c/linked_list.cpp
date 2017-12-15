//////////////////////////////////////////////////////////////////////////////
//     Name: linkedlist.cpp
//
//  Summary: Object-oriented approach to linked lists. The list delegates 
//           to the node.  The node is an abstract data type. Three types 
//           of nodes are used, head nodes, tail nodes and internal nodes.
//           Only the internal nodes hold data.
//
//           The Data class is created to serve as an object to hold in the
//           linked list.
//
//           Use a linked list instead of an array when:
//             1.  The number of data elements is unpredictable.
//             2.  The list needs to be sorted.
//
//  Adapted: Tue 19 Mar 2002 22:00:20 (Bob Heckel -- Teach Yourself C++ Jesse
//                                     Liberty ch. 19)
//////////////////////////////////////////////////////////////////////////////

// TODO what's wrong with the cin statements?  Is it Cygwin?
#include <iostream>
#include <stdio.h>

enum { IsSmaller, IsLarger, IsSame };

//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// Data class to insert into the linked list.  Any class in this linked list
// must support two methods: Show (displays the value) and Compare (returns
// relative position).
class Data
{
public:
  Data(int val):myValue(val) { printf("new Data object constructor\n"); }
  ~Data() { printf("Data object destructor\n"); }
  int Compare(const Data &);   // compare itself with other Data objects
  void Show() { std::cout << myValue << std::endl; }
private:
  int myValue;   // hold user's entered integer
};

// Decide where in the list a particular object belongs.
int Data::Compare(const Data & theOtherData) {
  if (myValue < theOtherData.myValue)
    return IsSmaller;

  if (myValue > theOtherData.myValue)
    return IsLarger;
  else
    return IsSame;
}
//|
//~~~~~~~~~~~~~~~~~~~~~~~~


// Forward declarations.
class Node;         // Abstract data type (ADT)
class InternalNode; // is a Node
class TailNode;     // is a Node
class HeadNode;     // is a Node

//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// ADT representing the node object in the list.  Every derived class *must*
// override Insert() and Show().
// Everything defined inline.
class Node
{
public:
  Node() { printf("new Node object constructor\n"); }
  virtual ~Node() {}
  virtual Node * Insert(Data * theData) =0;
  virtual void Show() =0;
private:
};
//|
//~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// This is the node which holds the actual object.  In this case the object is
// of type Data.  We'll see how to make this more general when we cover
// templates.
class InternalNode : public Node
{
public:
  InternalNode(Data* theData, Node* next);
  virtual ~InternalNode() { delete myNextnode; delete myData; }
  virtual Node* Insert(Data* theData);
  virtual void Show() { myData->Show(); myNextnode->Show(); }   // delegate!
private:
    Data * myData;       // the data itself
    Node * myNextnode;   // points to next node in the linked list
};

// All the constructor does is to initialize.
InternalNode::InternalNode(Data* theData, Node* next):
myData(theData), myNextnode(next) {
  printf("new InternalNode object constructor\n"); 
}

// The meat of the list.  When you put a new object into the list it is passed
// to the node which figures out where it goes and inserts it into the list.
Node * InternalNode::Insert(Data* theData) {
  // Is the new guy bigger or smaller than me?
  int result = myData->Compare(*theData);

  switch(result) {
    // By convention if it is the same as me it comes first.
    case IsSame:      // fall through
    case IsLarger:    // new data comes before me
      { // mandatory braces
        InternalNode* dataNode = new InternalNode(theData, this);
        return dataNode;
      }
    // It is bigger than I am so pass it on to the next node and let *him*
    // handle it.
    case IsSmaller:
      myNextnode = myNextnode->Insert(theData);
      return this;
  }

  return this;
}
//|
//~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// Tail node is just a sentinel.
class TailNode : public Node
{
public:
  TailNode() {printf("new TailNode object constructor\n"); }
  virtual ~TailNode() {}
  virtual Node* Insert(Data* theData);
  virtual void Show() {}
private:
};

// If data comes to me, it must be inserted before me as I am the tail and
// *nothing* comes after me.
Node * TailNode::Insert(Data * theData) {
  InternalNode * dataNode = new InternalNode(theData, this);

  printf("dataNode %p\n", dataNode); 

  return dataNode;
}
//|
//~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// Head node has no data, it just points to the very beginning of the list.
class HeadNode : public Node
{
public:
  HeadNode();
  virtual ~HeadNode() { delete myNextnode; }
  virtual Node * Insert(Data * theData);
  virtual void Show() { myNextnode->Show(); }
private:
    Node * myNextnode;
};

// As soon as the head is created it creates the tail.
HeadNode::HeadNode() {
  printf("new HeadNode object constructor\n"); 
  myNextnode = new TailNode;
  printf("myNextnode %p\n", myNextnode); 
}

// Nothing comes before the head so just pass the data on to the next node.
Node * HeadNode::Insert(Data * theData) {
  myNextnode = myNextnode->Insert(theData);

  return this;
}
//|
//~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~
//|
// I get all the credit and do none of the work.  So does this class.
class LinkedList
{
public:
  LinkedList();
  ~LinkedList() { delete myHead; }
  void Insert(Data * theData);
  void ShowAll() { myHead->Show(); }
private:
  HeadNode * myHead;
};

// At birth, I create the head node.  It creates the tail node.  So an empty
// list points to the head which points to the tail and has nothing between.
LinkedList::LinkedList() {
  printf("new LinkedList object constructor\n"); 
  myHead = new HeadNode;
  printf("myHead %p\n", myHead); 
}

// Delegate, delegate, delegate.
void LinkedList::Insert(Data * pData) {
  // myHead is type HeadNode and has been defined in the LinkedList
  // constructor.
  myHead->Insert(pData);  
}

// Test driver program.
int main() {
  Data * pData;
  int val;
  LinkedList ll;

  // Ask the user to produce some values put them in the list.
  for ( ;; ) {
    ///std::cout << "What value? (0 to stop): ";
    printf("number? ");
    ///std::cin >> val;
    scanf("%d", &val);
    if ( !val )
      break;
    pData = new Data(val);
    printf("ptr to new Data defined.  Prepare to insert.\n");
    ll.Insert(pData);
  }

  // Now walk the list and show the data.
  ll.ShowAll();

  return 0;  // ll falls out of scope and is destroyed!
}
