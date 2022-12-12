#include <iostream>

using namespace std;

// Must come before One since One inherits from it.
class Two
{
 public:
   Two() { 
     cout << "(1)Program "; 
   }
 private:
};  // <--- don't forget semi.

class Three
{
 public:
   Three() { 
     cout << "(3)objects "; 
   }
 private:
};

// Must come before One since One creates a Four object.
class Four
{
 public:
   Four() { 
     cout << "(2)makes "; 
   }
 private:
};

// FIRST inherit.
class One : public Two
{
 public:
   One() { 
     // THIRD construct pub obj.
     Three threeobj;
     // FOURTH spew.
     cout << "(4)with class." << endl; 
   }
 private:
   // SECOND construct private obj.
   Four _fourobj;
};


int main(void) {
  One oneobj;
  return 0;
}
