//////////////////////////////////////////////////////////////////////////////
//     Name: /split_on_whitesp.cpp
//
//  Summary: Demo of splitting a file on whitespace.  Get words.
//
//  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
//////////////////////////////////////////////////////////////////////////////
#include <string>
#include <iostream>
#include <fstream>
#include <vector>
using namespace std;

int main(int argc, char *argv[]) {
  string word;
  vector<string> v_of_words;

  ifstream in(argv[1]);

  // Crude one word at a time.
  while ( in >> word)
    // These string objects are pushed onto the back of the vector v_of_words.
    v_of_words.push_back(word);      // add the word to the end

  for ( int i=0; i<v_of_words.size(); i++ )
    cout << v_of_words[i] << endl;
} 
