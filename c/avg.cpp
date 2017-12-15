//////////////////////////////////////////////////////////////////////////////
//     Name: avg.cpp
//
//  Summary: Demo of creating an Avg class. 
//
//  Adapted: Sat, 18 Nov 2000 20:55:49 (Bob Heckel -- Bartosz Milewski
//                                                    tutorial)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

class Avg {
 public:
   // TODO initializes?
   Avg() : _sum(0), _count(0) {}

   void Put(double n) {
     _sum = _sum + n;
     ++_count;
   }

   double Get() const {
     return _sum / _count;
   }

 private:
    double _sum;
    int    _count;
};  // <--- don't forget semi.


int main(void) {
  double x;
  Avg avgobj;

  avgobj.Put(5);
  avgobj.Put(7);
  x = avgobj.Get();
  cout << x;

  return 0;
}
