//////////////////////////////////////////////////////////////////////////////
//     Name: arr_of_struct.cpp
//
//  Summary: Demo of using an array of structs.
//
//  Adapted: Tue 23 Jul 2002 19:55:45 (Bob Heckel -- C++ Primer Plus 4th ed
//                                     Stephen Prata)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
using namespace std;

struct inflatable {
  char name[20];
  float volume;
  double price;
};


int main() {
  // 1.
  // Initialize.
  inflatable bouquet = { "sunflower", 0.20, 12.49 };

  cout << "bouquet struct: " << bouquet.name << " for ";
  cout << bouquet.price << endl;

  // 2.
  inflatable wad_o_flower;
  // Assignable.
  wad_o_flower = bouquet;
  cout << "wad_o_flower struct: " << wad_o_flower.name << " for ";
  cout << wad_o_flower.price << endl;


  // 3.
  // Initialize.
  inflatable guests[2] = {
                           { "Bambi", 0.5, 21.99 },      // 1st struct in arr
                           { "Godzilla", 2000, 565.99 }  // 2nd struct in arr
                         };

  cout << "guests arr of struct: " << guests[1].name << " for ";
  cout << guests[1].price << endl;

  return 0;
}
