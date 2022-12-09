/*****************************************************************************
 *     Name: stringof.c
 *
 *  Summary: Return a string of len length filled with char ch.
 *
 *  Created: Thu 01 Aug 2002 14:39:44 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>

char * stringof(char repeatch, int ntimes) {
  char *buf;

  if ( ( buf = (char *)malloc(ntimes+1)) == NULL ) {
    perror( "Not enough memory to allocate buffer.\n");
    exit(1);
  }

  memset(buf, repeatch, ntimes);
  buf[ntimes] = '\0';

  return buf;
}


int main(void) {
  char ch = 'Z';
  int nrepeat = 32;

  printf("Voila: %s\n", stringof(ch, nrepeat));

  return 0;
}
