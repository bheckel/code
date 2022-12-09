/*****************************************************************************
 *     Name: strchr.c
 *
 *  Summary: Demo of extracting elements from argv.
 *           E.g. $ strchr foo baXcdr
 *
 *  Created: Wed 05 Dec 2001 11:19:17 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

int split(char *the_args[]) {
  char *the_substr;

  printf("argv[1] is: %s\n", &(the_args[1][0]));
  printf("argv[2] is: %s\n", &(the_args[2][0]));

  /*                                  delimiter */
  the_substr = strchr(&(the_args[2][0]), 'X');
  the_args[2] = ++the_substr;

  return 0;
}

int main(int argc, char *argv[]) {
  split(argv);
  printf("back in main: %s\n", argv[2]);

  return 0;
}

