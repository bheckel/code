//////////////////////////////////////////////////////////////////////////////
//     Name: class_simple.h  (see class_simple.cpp)
//
//  Summary: Demo of using a basic, almost useless, class.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 14)
//////////////////////////////////////////////////////////////////////////////
#ifndef USEFUL_H
#define USEFUL_H
class X {
  ///private:
    int i;
  public:
    X() { i = 0; }
    void set(int ii) { i = ii; }
    int read() const { return i; }
    int permute() { return i = i * 42; }
};
#endif 
