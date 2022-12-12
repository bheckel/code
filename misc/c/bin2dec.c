/*****************************************************************************
 *     Name: bin2dec.c
 *
 *  Summary: Convert a binary number to decimal radix.
 *
 *  Adapted: Wed 27 Mar 2002 10:37:35 (Bob Heckel -- Chuck Allison Code
 *                                     Capsules)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

#define BUFSIZE 64
#define MAXBITS 15     /* Largest value allowed is 32767 */

int fgetb(FILE *fp) {
  int i;
  unsigned sum = 0, value = 1;
  char buf[BUFSIZE];

  //                     scanset
  if ( !fp || fscanf(fp," %[01]", buf) != 1 || strlen(buf) > MAXBITS )
    return EOF;

  for ( i = strlen(buf) - 1; i >= 0; --i ) {
    if ( buf[i] == '1' )
      sum += value;
    value *= 2;
  }

  return sum;
}

int main(void) {
  ///int n = fgetb(stdin);
  int n;

  puts("Enter binary number e.g. 101");
  n = fgetb(stdin);

  printf("decimal number is %d\n", n);

  return 0;
}
