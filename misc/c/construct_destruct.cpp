//////////////////////////////////////////////////////////////////////////////
//     Name: construct_destruct.cpp
// 
//  Summary: Demo of constructing and destructing an object. An object cannot
//           be created unless it is also initialized (compile error
//           otherwise).
//           
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

class Tree {
  int height;
public:
  Tree(int initialHeight);  // constructor
  ~Tree();                  // destructor
  void grow(int years);
  void printsize();
};

Tree::Tree(int initialHeight) {
  height = initialHeight;
}

Tree::~Tree() {
  printsize();
  cout << "inside Tree destructor, tree was just chopped down" << endl;
}

void Tree::grow(int years) {
  height += years;
}

void Tree::printsize() {
  cout << "Tree height is " << height << endl;
}

int main() {
  cout << "before opening brace" << endl << endl;

  {
    Tree t(12);
    cout << "after Tree creation" << endl;
    t.printsize();
    t.grow(4);
    cout << "before closing brace, start destruction" << endl;
  }
  // You can see that the destructor is automatically called at the closing
  // brace of the scope that encloses it.

  cout << endl << "after closing brace" << endl;
} 
