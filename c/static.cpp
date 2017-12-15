//////////////////////////////////////////////////////////////////////////////
//     Name: static.cpp
// 
//  Summary: Demo of static in terms of retaining a value between function
//           calls.
//
//          External (global) variables initialize to 0.
//          Local variables initialize to garbage.
//           
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++ Ch 10)
// Modified: Sun 28 Jul 2002 14:35:14 (Bob Heckel -- added variables that
//                                     don't do anything but illustrate
//                                     linkage and duration)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

// All static duration variables persist from execution to end of pgm.  These
// two can be used from here to end of this file.  thisorotherfiles is able to
// do even more, being accessible from other files in the project, as long as
// the other file(s) declare it like this:  extern int thisorotherfiles;
int thisorotherfiles = 42;     // static duration, external linkage (global)
static int onlythisfile = 66;  // static duration, internal linkage

char oneChar(const char *charArray = 0) {
  // This object is initialized only once, the first time the function is
  // called, and then retains its value between function invocations.  The
  // storage for this object is not on the stack but instead in the program's
  // static data area.
  static const char* s; 
  static int onlythisfn;      // static duration, no linkage   

  if ( charArray ) {
    s = charArray;
    return *s;
  }
  else
  if ( *s == '\0' )
    return 0;

  return *s++;
}

char *a = "abcdefg";

// The notion of a static local variable retaining its value between calls to
// main() really makes no sense: A variable can't remain in existence between
// program executions. Within main(), therefore, there is no difference
// between automatic and static local variables. You can define a local
// variable in main() as being static, but it has no effect.                                  
int main() {
  oneChar(a); // initialize oneChar()'s s to a

  char c;
  // Each subsequent call to oneChar() without an argument produces the
  // default value of zero for charArray, which indicates to the function that
  // you are still extracting characters from the previously initialized value
  // of s.
  while ( (c = oneChar()) != 0 )
    cout << c << endl;

  return 0;
}
