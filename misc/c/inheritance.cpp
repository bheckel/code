//////////////////////////////////////////////////////////////////////////////
//     Name: inheritance.cpp
//
//  Summary: Demo of inheritance, construction and destruction.
//
//  Adapted: Sat, 18 Nov 2000 20:55:49 (Bob Heckel -- Bartosz Milewski
//                                                    tutorial)
//////////////////////////////////////////////////////////////////////////////

#include <iostream>

using namespace std;

class LivingBeing
{
 public:
   LivingBeing(int counter, int kindofthing) : _i(counter), _thing(kindofthing) {
     cout << "\nLiving creature " << counter << " created\n";
   }

   ~LivingBeing() {
     cout << "LivingBeing" << _i << " obliterated." << _thing << "\n";
   }

 private:
   int _i;
   int _thing;
};  // <--- don't forget semi.


class Humanoid : public LivingBeing    // Humanoid IS-A LivingBeing
{
  public:
    Humanoid(int counter) : LivingBeing(counter, 1) {
      cout << " ...wait, it's a human!" << endl;
    }

  private:
    ///int _typething;
};


class Tomato : public LivingBeing    // Tomato IS-A LivingBeing
{
  public:
    Tomato(int counter) : LivingBeing(counter, 2) {
      cout << " ...wait, it's a tomato!" << endl;
    }

  private:
    ///int _typething = 1;
};


int main(void) {
  cout << "Time to live oooooooooooooooooooo";

  Humanoid humanoidobj(99);
  Tomato tomatoobj(88);

  cout << "Time to die xxxxxxxxxxxxxxxxxxxxx\n";

  return 0;
}
