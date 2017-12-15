// Fig. 14.4: fig14_04.cpp
// Create a sequential file
#include <iostream>

using std::cout;
using std::cin;
using std::ios;
using std::cerr;
using std::endl;

#include <fstream>

using std::ofstream;


int main() {
  // ofstream constructor opens file.
  // File is overwritten on each run.
  ofstream outClientFile("junk.dat", ios::out); 

  if ( !outClientFile ) {  // overloaded ! operator
    cerr << "File could not be opened" << endl;
    exit(1);    // prototype in cstdlib
  }

  cout << "Enter the account (int), name (char), and balance (double):\n"
       << "Enter end-of-file to end input.\n? ";

  int account;
  char name[30];
  double balance;

  while ( cin >> account >> name >> balance ) {
    outClientFile << account << ' ' << name << ' ' << balance << '\n';
    cout << "? ";
  }

  return 0;  // ofstream destructor closes file
}



/**************************************************************************
 * (C) Copyright 2000 by Deitel & Associates, Inc. and Prentice Hall.     *
 * All Rights Reserved.                                                   *
 *************************************************************************/
