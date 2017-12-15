/*****************************************************************************
 *     Name: round.c
 *
 *  Summary: Round a real (floating point) number.
 *
 *  Adapted: Sat 23 Mar 2002 18:58:42 (Bob Heckel -- Chuck Allison Thinking 
 *                                     in C++ CDROM)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  float x;
  int n;
  
  printf("Enter a real number: ");
  // Not sure this is always necessary.
  fflush(stdout);
  scanf("%f", &x);
  n = (int)(x + 0.5);
  printf("%f rounded == %d\n", x, n);

  return 0;
}
