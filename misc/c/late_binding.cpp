//////////////////////////////////////////////////////////////////////////////
//     Name: late_binding.cpp
//
//  Summary: Demo of late binding.
//
//  Adapted: Wed 31 Oct 2001 14:06:05 (Bob Heckel -- Thinking in C++ Ch 15)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

enum note { middleC, Csharp, Cflat };

class Instrument {
  public:
    ///void play(note) const {  // would force Instrument::play for each call
    //
    // The keyword virtual tells the compiler it should NOT perform early
    // binding. Instead, it should automatically install all the mechanisms
    // necessary to perform late binding. This means that if you call play()
    // for a Brass object through an address for the base-class Instrument,
    // you'll get the proper function.
    virtual void play(note) const {
      cout << "Instrument::play" << endl;
    }
    virtual char *what() const {
      return "Instrument";
    }
    // Assume this will modify the object:
    virtual void adjust(int) {}
};

class Wind : public Instrument {
  public:
    void play(note) const {
      cout << "Wind::play" << endl;
    }
    char *what() const { return "Wind"; }
    void adjust(int) {}
};

class Percussion : public Instrument {
  public:
    void play(note) const {
      cout << "Percussion::play" << endl;
    }
    char *what() const { return "Percussion"; }
    void adjust(int) {}
};

class Stringed : public Instrument {
  public:
    void play(note) const {
      cout << "Stringed::play" << endl;
    }
    char *what() const { return "Stringed"; }
    void adjust(int) {}
};

class Brass : public Wind {
  public:
    void play(note) const {
      cout << "Brass::play" << endl;
    }
    char *what() const { return "Brass"; }
};

class Woodwind : public Wind {
  public:
    void play(note) const {
      cout << "Woodwind::play" << endl;
    }
    char *what() const { return "Woodwind"; }
};


void tune(Instrument& i) {
  // ...
  i.play(middleC);
}

// New function:
void f(Instrument& i) { i.adjust(1); }

// Upcasting during array initialization:
Instrument *A[] = {
  new Wind,
  new Percussion,
  new Stringed,
  new Brass,
};

int main() {
  Wind flute;
  Percussion drum;
  Stringed violin;
  Brass flugelhorn;
  Woodwind recorder;

  tune(flute);
  tune(drum);
  tune(violin);
  tune(flugelhorn);
  tune(recorder);

  f(flugelhorn);
}
