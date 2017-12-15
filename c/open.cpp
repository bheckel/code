//////////////////////////////////////////////////////////////////////////////
//     Name: open.cpp
//
//  Summary: Demo of opening a file using C++.
//
//  Adapted: Sat 12 Jan 2002 10:03:33 (Bob Heckel -- cplusplus.com 
//                                     C++ tutorial 5.4)
// Modified: Mon 10 Feb 2003 14:31:43 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream.h>
#include <fstream.h>

int main () {
  char buffer[256];

  ifstream examplefile("junk");

  if ( ! examplefile.is_open() ) { 
    cout << "Error opening file"; 
    exit(1); 
  }

  while (! examplefile.eof() ) {
    examplefile.getline(buffer,100);
    cout << buffer << endl;
  }

  return 0;
}

