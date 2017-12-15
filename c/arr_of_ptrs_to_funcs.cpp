//////////////////////////////////////////////////////////////////////////////
//     Name: arr_of_ptrs_to_funcs.cpp
// 
//  Summary: Using an array of pointers to functions.
//           
//           Creates some dummy functions using a preprocessor macro, then
//           creates an array of pointers to those functions using automatic
//           aggregate initialization. As you can see, it is easy to add or
//           remove functions from the table (and thus, functionality from the
//           program) by changing a small amount of code.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

// A macro to define dummy functions (uses preprocessor's stringizer feature):
#define DF(N)  void N() { \
                      cout << "function " #N " called..." << endl; \
                    }

DF(a); DF(b); DF(c); DF(d); DF(e); DF(f); DF(g);

void (*func_table[])() = { a, b, c, d, e, f, g };


int main() {
  while( 1 ) {
    cout << "press a key from 'a' to 'g' or q to quit" << endl;

    char c, cr;
    cin.get(c); cin.get(cr); // second one for tossing CR out

    if ( c == 'q' ) 
      break; // out of while( 1 )

    if ( c < 'a' || c > 'g' ) 
      continue;

    (*func_table[c - 'a'])();
  }
} 
