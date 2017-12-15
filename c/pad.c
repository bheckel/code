/*****************************************************************************
 *     Name: pad.c
 *
 *  Summary: Pad the end of a string with n spaces.
 *
 *  Created: Thu 01 Aug 2002 14:39:44 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char * pad(char *str, int nblanks) {
  char *buf;
  size_t len = strlen(str);

  if ( ( buf = (char *)malloc(len+nblanks)) == NULL ) {
    perror("Not enough memory to allocate buffer.\n");
    exit(1);
  }

  memset(buf, ' ', len+nblanks);
  buf[len-1] = '\0';

  return strncpy(buf, str, len);
}


int main(void) {
  char str[] = "Zoo";
  int npads = 3;

  printf("Padded: xxxx%sxxxx\n", pad(str, npads));

  return 0;
}
