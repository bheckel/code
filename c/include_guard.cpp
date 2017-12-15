//////////////////////////////////////////////////////////////////////////////
//     Name: include_guard.cpp
// 
//  Summary: Simple inclusion guard header that prevents re-definition
//           
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#ifndef SIMPLE_H
#define SIMPLE_H
struct Simple {
  int i,j,k;
  initialize() { i = j = k = 0; }
};
#endif // SIMPLE_H 

// ...foo...
