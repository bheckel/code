 // ***********************************************
 //    FILE:        Listing 23.2
 //
 //    PURPOSE:    Demonstrate parameterized list
 //    NOTES:        
 //
 //  COPYRIGHT:  Copyright (C) 1997 Liberty Associates, Inc.
 //                All Rights Reserved
 //
 // Demonstrates an object-oriented approach to parameterized
 // linked lists. The list delegates to the node.
 // The node is an abstract Object type. Three types of 
 // nodes are used, head nodes, tail nodes and internal 
 // nodes. Only the internal nodes hold Object. 
 // 
 // The Object class is created to serve as an object to 
 // hold in the linked list.
 //
 // ***********************************************
 
 #include <iostream>
 
 enum { kIsSmaller, kIsLarger, kIsSame};
 
 // Object class to put into the linked list
 // Any class in this linked list must support two methods:
 // Show (displays the value) and 
 // Compare (returns relative position)
 class Data
 {
 public:
     Data(int val):myValue(val){}
     ~Data()
     {
         std::cout << "Deleting Data object with value: ";
         std::cout << myValue << "\n";
     }
     int Compare(const Data &);
     void Show() { std::cout << myValue << std::endl; }
 private:
     int myValue;
 };
 
 // compare is used to decide where in the list
 // a particular object belongs. 
 int Data::Compare(const Data & theOtherObject)
 {
     if (myValue < theOtherObject.myValue)
         return kIsSmaller;
     if (myValue > theOtherObject.myValue)
         return kIsLarger;
     else
         return kIsSame;
 }
 
 // Another class to put into the linked list
 // Again, every class in this linked 
 // list must support two methods:
 // Show (displays the value) and 
 // Compare (returns relative position)
 class Cat
 {
 public:
     Cat(int age): myAge(age){}
     ~Cat()
     { 
         std::cout << "Deleting " << myAge 
             << " years old Cat.\n";
     }
     int Compare(const Cat &);
     void Show() 
     { 
         std::cout << "This cat is " << myAge 
             << " years old\n"; 
     }
 private:
     int myAge;
 };
 
 
 // compare is used to decide where in the list
 // a particular object belongs. 
 int Cat::Compare(const Cat & theOtherCat)
 {
     if (myAge < theOtherCat.myAge)
         return kIsSmaller;
     if (myAge > theOtherCat.myAge)
         return kIsLarger;
     else
         return kIsSame;
 }
 
 
 // ADT representing the node object in the list
 // Every derived class must override Insert and Show
 template <class T>
 class Node
 {
 public:
     Node(){}
     virtual ~Node(){}
     virtual Node * Insert(T * theObject)=0;
     virtual void Show() = 0;
 private:
 };
 
 template <class T>
 class InternalNode: public Node<T>
 {
 public:
     InternalNode(T * theObject, Node<T> * next);
     virtual ~InternalNode(){ delete myNext; delete myObject; }
     virtual Node<T> * Insert(T * theObject);
     virtual void Show() // delegate!
     { 
         myObject->Show(); myNext->Show(); 
     }  
 private:
     T * myObject;  // the Object itself
     Node<T> * myNext;    // points to next node in the linked list
 };
 
 // All the constructor does is initialize
 template <class T>
 InternalNode<T>::InternalNode(T * theObject, Node<T> * next):
 myObject(theObject),myNext(next)
 {
 }
 
 // the meat of the list
 // When you put a new object into the list
 // it is passed to the node which figures out
 // where it goes and inserts it into the list
 template <class T>
 Node<T> * InternalNode<T>::Insert(T * theObject)
 {
     // is the new guy bigger or smaller than me?
     int result = myObject->Compare(*theObject);
 
     switch(result)
     {    
     // by convention if it is the same as me it comes first
     case kIsSame:        // fall through
     case kIsLarger:    // new Object comes before me
         {
             InternalNode<T> * ObjectNode = 
             new InternalNode<T>(theObject, this);
             return ObjectNode;
         }
     // it is bigger than I am so pass it on to the next
     // node and let HIM handle it.
     case kIsSmaller:
         myNext = myNext->Insert(theObject);
         return this;
     }
     return this;  // appease MSC
 }
 
 
 // Tail node is just a sentinel
 template <class T>
 class TailNode : public Node<T>
 {
 public:
     TailNode(){}
     virtual ~TailNode(){}
     virtual Node<T> * Insert(T * theObject);
     virtual void Show() { }
 private:
 };
 
 // If Object comes to me, it must be inserted before me
 // as I am the tail and NOTHING comes after me
 template <class T>
 Node<T> * TailNode<T>::Insert(T * theObject)
 {
     InternalNode<T> * ObjectNode = 
         new InternalNode<T>(theObject, this);
     return ObjectNode;
 }
 
 // Head node has no Object, it just points
 // to the very beginning of the list
 template <class T>
 class HeadNode : public Node<T>
 {
 public:
     HeadNode();
     virtual ~HeadNode() { delete myNext; }
     virtual Node<T> * Insert(T * theObject);
     virtual void Show() { myNext->Show(); }
 private:
     Node<T> * myNext;
 };
 
 // As soon as the head is created
 // it creates the tail
 template <class T>
 HeadNode<T>::HeadNode()
 {
     myNext = new TailNode<T>;
 }
 
 // Nothing comes before the head so just
 // pass the Object on to the next node
 template <class T>
 Node<T> * HeadNode<T>::Insert(T * theObject)
 {
     myNext = myNext->Insert(theObject);
     return this;
 }
 
 // I get all the credit and do none of the work
 template <class T>
 class LinkedList
 {
 public:
     LinkedList();
     ~LinkedList() { delete myHead; }
     void Insert(T * theObject);
     void ShowAll() { myHead->Show(); }
 private:
     HeadNode<T> * myHead;
 };
 
 // At birth, i create the head node
 // It creates the tail node
 // So an empty list points to the head which
 // points to the tail and has nothing between
 template <class T>
 LinkedList<T>::LinkedList()
 {
     myHead = new HeadNode<T>;
 }
 
 // Delegate, delegate, delegate
 template <class T>
 void LinkedList<T>::Insert(T * pObject)
 {
     myHead->Insert(pObject);
 }
 
 void myFunction(LinkedList<Cat>& ListOfCats);
 void myOtherFunction(LinkedList<Data>& ListOfData);
 
 // test driver program
 int main()
 {
     LinkedList<Cat>  ListOfCats;
     LinkedList<Data> ListOfData;
 
     myFunction(ListOfCats);
     myOtherFunction(ListOfData);
 
     // now walk the list and show the Object
     std::cout << "\n";
     ListOfCats.ShowAll();
     std::cout << "\n";
     ListOfData.ShowAll();
     std::cout << "\n ************ \n\n";
     return 0;  // The lists fall out of scope and are destroyed!
 }
 
 void myFunction(LinkedList<Cat>& ListOfCats)
 {
     Cat * pCat;
     int val;
 
     // ask the user to produce some values
     // put them in the list
     for (;;)
     {
         std::cout << "\nHow old is your cat? (0 to stop): ";
         std::cin >> val;
         if (!val)
             break;
         pCat = new Cat(val);
         ListOfCats.Insert(pCat);
     }
 
 }
 
 void myOtherFunction(LinkedList<Data>& ListOfData)
 {
     Data * pData;
     int val;
 
     // ask the user to produce some values
     // put them in the list
     for (;;)
     {
         std::cout << "\nWhat value? (0 to stop): ";
         std::cin >> val;
         if (!val)
             break;
         pData = new Data(val);
         ListOfData.Insert(pData);
     }
 
 }
