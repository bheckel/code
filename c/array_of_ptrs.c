/* Initializing an array of pointers to type char. */
/*  Adapted: Thu 19 Jul 2001 21:51:38 (Bob Heckel -- InformIT) */

#include <stdio.h>

int main(void) {
  char *message[8] = { "Four", "score", "and", "seven",
                       "years", "ago,", "our", "forefathers" };
  int count;

  for (count = 0; count < 8; count++)
     printf("%s ", message[count]);

  printf("\n");

  return(0);
}
