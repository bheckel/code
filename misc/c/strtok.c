/*****************************************************************************
 *     Name: strtok.c
 *
 *  Summary: Demo of extracting elements from argv and splitting on slash.
 *           E.g. $ strtok 12/1/2001 12/5/2001
 *
 *  Created: Wed 05 Dec 2001 11:19:17 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

int split(char *sendout, char *the_args[]) {
  const char delimiter[] = "/";
  char *token;
  char *arg1;
  char *arg2;
  char *arg3;

  arg1 = &(the_args[1][0]);
  arg2 = &(the_args[2][0]);

  token = strtok(arg1, delimiter);
  printf("mo: %s\n", token);
  token = strtok(NULL, delimiter);
  printf("day: %s\n", token);
  token = strtok(NULL, delimiter);
  printf("yr: %s\n", token);
  token = strtok(arg2, delimiter);
  printf("mo: %s\n", token);
  token = strtok(NULL, delimiter);
  printf("day: %s\n", token);
  token = strtok(NULL, delimiter);
  printf("yr: %s\n", token);

  return 0;
}

int main(int argc, char *argv[]) {
  char *useme;

  split(useme, argv);
  ///printf("back in main: %s\n", argv[2]);

  return 0;
}

