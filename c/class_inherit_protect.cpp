//////////////////////////////////////////////////////////////////////////////
//     Name: class_inherit.cpp
//
//  Summary: Demo of using protected inheritance.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 14)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

class Base {
  private:
    int i;
  protected:
    int read() const { return i; }
    void set(int ii) { i = ii; }
  public:
    Base(int ii = 0) : i(ii) {}
    int value(int m) const { return m * i; }
};

class Derived : public Base {
  private:
    int j, x;
  public:
    Derived(int jj = 0) : j(jj) {}
    void change(int x) { set(x); }
    void printme() { cout << "greetings from Derived: " << read() << endl; }
}; 


int main() {
  Derived d;

  d.printme();
  d.change(10);
  d.printme();
  // Seamlessly use Base's function value().
  cout << "d.value(5): " << d.value(5) << endl;
} 
