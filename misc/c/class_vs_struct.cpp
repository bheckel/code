//////////////////////////////////////////////////////////////////////////////
//     Name: class_vs_struct.cpp
//
//  Summary: Comparison of using classes vs. structs.
//           Similarity of struct and class.  Keyword class is identical to
//           keyword struct in every way except one: class defaults to
//           private, whereas struct defaults to public. 
//
//           Keyword struct only exists for backwards compatibility with C.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++ and
//                                     http://www.glenmccl.com)
//////////////////////////////////////////////////////////////////////////////

// Demo 1:
class Point {                                                                                        
  float x;                                                                                     
  float y;                                                                                     
public:                                                                                              
  Point(float, float);                                                                         
  float dist(const Point&);                                                                    
};               

// ...


// compare with the C version:

struct Point {                                                                                       
  float x;                                                                                     
  float y;                                                                                     
};                                                                                                   
                                                                                                    
typedef struct Point Point;                                                                          
                                                                                                    
float dist(Point*);  

// ...



// Demo 2:
#include <iostream>

struct A {
  // public:  not needed
  char f();
  int g();

  private:
  int i, j, k;
};

char A::f() { 
  return 'f'; 
}

int A::g() { 
  i = j = k = 0; 

  return 'g'; 
}

// Identical results are produced with:

class B {
  // private:  not needed
  int i, j, k;

  public:
  char f();
  int g();
};

char B::f() { 
  return 'F'; 
}

int B::g() { 
  i = j = k = 0; 

  return i + j + k; 
} 


int main() {
  A a;
  B b;

  cout << a.f() << endl; 
  cout << a.g() << endl;
  cout << b.f() << endl; 
  cout << b.g() << endl;
} 
