//////////////////////////////////////////////////////////////////////////////
//     Name: struct_simple.cpp
//
//  Summary: Demo of a simple struct.
//
//           Structs are declared like any other primitive type.
//
//  Adapted: Sat 22 Mar 2003 11:46:20 (Bob Heckel -- Deitel PPT slides)
// Modified: Sat 24 Jan 2004 21:07:48 (Bob Heckel)
//////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <string>
using namespace std;

/* Definition only.  Card1 is the structure name that is used to declare
 * variables of the Card1 structure type.  A new data type exists at this
 * point.  But no memory is reserved.
 */
struct Card1 {
  char *face;
  char *suit;
};

/* Definition with optional declarations. */
struct Card2 {
  char *face;
  char *suit;
} singleCard2, deck2[52], twocard[] = { {"kiNg","heArts"},{"tWo","clUbs"} },
  *ptrSingleCard2;


int main() {
  ///Card1 singleCard1, deck1[52], *ptrSingleCard1;
  Card1 singleCard1;

  /* Assignment style: */
  singleCard1.face = "Three";
  singleCard2.face = "Four";

  cout << singleCard1.face << endl;
  cout << singleCard2.face << endl;

  /* Initializer list style: */
  Card1 anotherSingle = { "Five", "Hearts" };
  
  cout << anotherSingle.face << endl;
  cout << anotherSingle.suit << endl;

  /* Demo of accessing the twocard array. */
  cout << twocard[1].suit << endl;

  return(0);
}
