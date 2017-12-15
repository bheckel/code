/*****************************************************************************
 *     Name: structure_mo.c
 *
 *  Summary: Demo of C structures (pointers, passing to functions, nested,
 *           etc.).
 *
 *  Created: Fri, 22 Dec 2000 19:24:00 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include "test.h"

/* Pointer to a monthtag structure. */
/*          -----------------     */
int totdays(struct monthtag *, int);

int main(int argc, char *argv[]) {
  int maxmo = 0;
  extern struct monthtag mystruct[];

  printf("In main() sizeof(mystruct[2]) is %d\n", sizeof(mystruct[2]));
  printf("In main() %s is %d days\n", mystruct[0].name, mystruct[0].days);
  printf("In main() %s is %d days\n", mystruct[1].name, mystruct[1].days);
  printf("In main() %s is %d days\n", mystruct[2].name, mystruct[2].days);
  printf("          %s's nest contains %d an int and %s a char\n", 
                                                        mystruct[2].name, 
                                                        mystruct[2].bird.imp, 
                                                        mystruct[2].bird.car);

  puts("Now add a new monthtag structure ([3]) name and days:");
  scanf("%s", &mystruct[3].name);
  scanf("%d", &mystruct[3].days);
  printf("In main() %s is %d days\n", mystruct[3].name, mystruct[3].days);

  /* Jan = 0, Feb = 1, Mar = 2 ... */
  maxmo = atoi(argv[1]);
  /* Must send an element, not just the name, if it's an array of structs. */
  /*                -----                                                  */
  totdays(&mystruct[maxmo], maxmo);
  printf("Back in main(), %s has, in fact, been corrupted to %d days\n", 
                                  mystruct[maxmo].name, mystruct[maxmo].days);

  return 0;
}

/*** int totdays(const struct monthtag * in, int i) { ***/
int totdays(struct monthtag * instruct, int i) {
  int j;
  int k = 0;

  printf("Now in totdays() max mo (%s) is %d days, monum is %d\n", 
                    instruct->name, (*instruct).days, instruct->monum);

  for ( j=0; i>=j; j++ ) {
    k += instruct->days;
    --instruct;
  }

  printf("----Sum of the %d months is %d days----\n", i+1, k);
  /* Rewind. */
  instruct += i+1;
  instruct->days = 99;
  printf("Still in totdays() max mo %s is changed to %d days\n", 
                                           instruct->name, instruct->days);

  return 0;
}

