/* tbit.c: Use bit operations from bit.h */
/* Adapted: Fri Aug 02 18:08:04 2002 (Bob Heckel -- Code Capsules Nov 93) */

/* To compile:
 * $ gcc -c bits.c bits.pgm.c
 * $ gcc -o bits.pgm.exe bits.o bits.pgm.o
 */

#include <stdio.h>
#include "bits.h"

int main(void) {
  int i;
  unsigned n = 0;
  size_t nb = nbits(n);
  
  /* Set the even bits */
  for ( i = 0; i < nb; i += 2 )
    n = set(n, i);
  printf("n == %04X (", n);
  fputb(n, stdout);
  printf("), count == %d\n", count(n));
  
  /* Toggle the upper half */
  for ( i = nb/2; i < nb; ++i )
    n = toggle(n,i);
  printf("n == %04X (", n);
  fputb(n, stdout);
  printf("), count == %d\n", count(n));
  
  /* Reset the lower half */
  for ( i = 0; i < nb/2; ++i )
     n = reset(n,i);
  printf("n == %04X (",n);
  fputb(n, stdout);
  printf("), count == %d\n", count(n));
  
  /* Read a bit string */
  fputs("Enter a bit string: ", stderr);
  n = fgetb(stdin);
  printf("n == %04X (", n);
  fputb(n,stdout);
  printf("), count == %d\n", count(n));
  
  return 0;
}
