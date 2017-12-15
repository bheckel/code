//////////////////////////////////////////////////////////////////////////////
//     Name: numberlines.cpp
//
//  Summary: Demo of numbering lines of a file.
//
//           May be better to use cat -n or nl
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <string>
#include <iostream>
#include <fstream>
#include <vector>
using namespace std;

int main(int argc, char *argv[]) {
  string line;
  vector<string> v;

  ifstream in(argv[1]);

  // File is opened and lines are read into string objects one at a time.
  while ( getline(in, line) )
    // These string objects are pushed onto the back of the vector v.
    v.push_back(line);      // add the line to the end
    // Once the while loop completes, the entire file is resident in memory,
    // inside v.

  // Add line numbers.
  for ( int i=0; i<v.size(); i++ )
    cout << i << ": " << v[i] << endl;
} 
