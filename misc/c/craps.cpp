// Fig. 3.10: fig03_10.cpp
// Craps.
// Adapted: Sun Feb 02 12:16:52 2003 (Bob Heckel -- good demo of enum)
#include <iostream>

using std::cout;
using std::endl;

// contains function prototypes for functions srand and rand
#include <cstdlib>
#include <ctime>   // contains prototype for function time

int rollDice( void );  // function prototype


int main() {
  int sum;
  int myPoint;

  // Enumeration constants represent game status.
  enum Status { CONTINUE, WON, LOST };

  Status gameStatus;  // can contain only CONTINUE, WON or LOST

  // Randomize random number generator using current time.
  srand(time(0)); 

  sum = rollDice();  // first roll of the dice

  // Determine game status and point based on sum of dice.
  switch ( sum ) {
    // Win on first roll.
    case 7: 
    case 11:            
         gameStatus = WON;
         break;
    // Lose on first roll.
    case 2: 
    case 3: 
    case 12:             
         gameStatus = LOST;
         break;
    // Remember point.
    default:            
           gameStatus = CONTINUE;
           myPoint = sum;
           cout << "Point is " << myPoint << endl;
           break;  // optional   

  }

  // While game not complete ...
  while ( gameStatus == CONTINUE ) { 
    sum = rollDice();           // roll dice again

    // Determine game status.
    if ( sum == myPoint )       // win by making point
      gameStatus = WON;
    else
      if ( sum == 7 )          // lose by rolling 7
        gameStatus = LOST;

  }

  // Display won or lost message.
  if ( gameStatus == WON )
    cout << "Player wins" << endl;
  else
    cout << "Player loses" << endl;

  return 0;  // indicates successful termination

} // end main


// Roll dice, calculate sum and display results.
int rollDice(void) {
  int die1;
  int die2;
  int workSum;

  die1 = 1 + rand() % 6;  // pick random die1 value
  die2 = 1 + rand() % 6;  // pick random die2 value
  workSum = die1 + die2;  // sum die1 and die2

  // Display results of this roll.
  cout << "Player rolled " << die1 << " + " << die2
       << " = " << workSum << endl;

  return workSum;

}


/**************************************************************************
 * (C) Copyright 1992-2003 by Deitel & Associates, Inc. and Prentice      *
 * Hall. All Rights Reserved.                                             *
 *                                                                        *
 * DISCLAIMER: The authors and publisher of this book have used their     *
 * best efforts in preparing the book. These efforts include the          *
 * development, research, and testing of the theories and programs        *
 * to determine their effectiveness. The authors and publisher make       *
 * no warranty of any kind, expressed or implied, with regard to these    *
 * programs or to the documentation contained in these books. The authors *
 * and publisher shall not be liable in any event for incidental or       *
 * consequential damages in connection with, or arising out of, the       *
 * furnishing, performance, or use of these programs.                     *
 *************************************************************************/
