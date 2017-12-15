/*****************************************************************************
 *     Name: htons.c
 *
 *  Summary: Demo of converting host to network byte order.
 *
 *  Created: Wed 10 Oct 2001 12:24:35 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>


int main(int argc, char *argv[]) {
  int shortie;

  shortie = atoi(argv[1]);
  printf("host to network short: %d\n", htons(shortie));

  return 0;
}
