//////////////////////////////////////////////////////////////////////////////
//     Name: early_binding.cpp
//
//  Summary: Demo of early binding.
//
//           Connecting a function call to a function body is called binding.
//           When binding is performed before the program is run (by the
//           compiler and linker), it's called early binding. You may not
//           have heard the term before because it’s never been an option
//           with procedural languages: C compilers have only one kind of
//           function call, and that's early binding.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 15)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

enum note { middleC, Csharp, Eflat };

class Instrument {
  public:
    ///virtual void play(note) const {  // late binding
    void play(note) const {
      cout << "in Instrument::play" << endl;
    }
};

// Wind objects are Instruments because they have the same interface:
class Wind : public Instrument {
  public:
    // Redefine interface function:
    void play(note) const {
      cout << "in Wind::play" << endl;
    }
};


// The compiler cannot know the correct function to call when it has only an
// Instrument address, so it uses Instrument instead of Wind.
void tune(Instrument& i) {
  // ...
  i.play(middleC);
}


int main() {
  Wind flute;
  tune(flute); // upcasting
  // The wrong output is printed to screen due to early binding.
} 
