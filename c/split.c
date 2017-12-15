/*****************************************************************************
 *     Name: split.c
 *
 *  Summary: Demo of extracting elements from a date string and splitting 
 *           on slash.
 *           E.g. $ split 12/1/2001
 *
 *  Created: Wed 05 Dec 2001 11:19:17 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

int split(char *the_arg, int iterations) {
  const char delimiter[] = "/";
  char *token;
  int i;

  token = strtok(the_arg, delimiter);
  printf("in split, mo: %s\n", token);
  for ( i=1; i<iterations; i++ ) {
    token = strtok(NULL, delimiter);
    printf("in split, mo: %s\n", token);
    // TODO push onto array.
  }

  return 0;
}


int main(int argc, char *argv[]) {
  split(argv[1], 3);

  return 0;
}

