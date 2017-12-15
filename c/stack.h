//////////////////////////////////////////////////////////////////////////////
//     Name: stack.h
//
//  Summary: Header file for stack class demo using a stack of integers.
//
//  Adapted: Sun, 19 Nov 2000 13:20:10 (Bob Heckel -- Bartosz Milewski
//                                      tutorial)
//////////////////////////////////////////////////////////////////////////////

// Death blow test.
///const int maxStack = 2;
const int maxStack = 3;

// Integer stack interface.
class IStack
{
public:
  // Initialize top-of-stack index to 0 (the start of the array).
  IStack() : _top(0) {}
  // Push declared, not defined.
  void Push(int i);
  int  Pop();
  int  Top();
private:
  int _top;
  int _arr[maxStack];
};  // <--- required for declaration, not definition.


// Character stack interface.
class CStack
{
public:
  CStack() : _top(0) {}
  void Push(char ch);
  char Pop();
  int  Counter() const;
private:
  int  _top;
  char _arr[maxStack];
};  // <--- required for declaration, not definition.
