/*****************************************************************************
 *     Name: struct_pass_ptr.c
 *
 *  Summary: Demo of C structures (pointers, passing to functions), both
 *           passing structure to a function and passing a pointer to a
 *           function.
 *
 *  Created: Sat, 23 Dec 2000 23:43:53 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

struct gasPTR {
  float distance;
  float gals;
  float mpg;
};

struct gasNONPTR {
  float distance;
  float gals;
  float mpg;
};

int fnPTR(struct gasPTR *);
struct gasNONPTR fnNONPTR(struct gasNONPTR);


int main(int argc, char *argv[]) {
  struct gasPTR mystruct = {
    100.00,
     20.00
  };

  struct gasNONPTR mystructNONPTR = {
    200.00,
     50.00
  };

  /* Version with ptr. */
  /* Intermediate synthetic variable ps only here for learning purposes. */
  struct gasPTR * ps;
  ps = &mystruct;
  fnPTR(ps);
  printf("MPG using ptrs: \t\t%f\n", mystruct.mpg);

  /* Version without ptr.                   */
  /*                        Pass by value   */
  /*                        --------------  */
  mystructNONPTR = fnNONPTR(mystructNONPTR);
  printf("MPG without using ptrs: \t%f\n", mystructNONPTR.mpg);

  return 0;
}


int fnPTR(struct gasPTR * in) {
  int x, y;

  printf("DEBUG> %f <DEBUG\n", in->distance);
  x = in->distance;
  y = in->gals;
  in->mpg = x / y;

  return 0;
}


struct gasNONPTR fnNONPTR(struct gasNONPTR trip) {
  int x, y;

  x = trip.distance;
  y = trip.gals;
  trip.mpg = x / y;

  return trip;
}
