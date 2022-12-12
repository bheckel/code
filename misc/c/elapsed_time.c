/*****************************************************************************
 *     Name: elapsed_time.c
 *
 *  Summary: Calculate time between two points.
 *
 *  Adapted: Tue, 16 Jan 2001 16:49:23 (Bob Heckel -- Using C on the Unix
 *                                      System)
 *****************************************************************************
*/

#include <stdio.h>
#include <sys/time.h>

int main() {
  int x = 979681361;
  int y = 979681301;
  int session;

  session = x - y;

  printf("%.8s elapsed\n", asctime(gmtime(&session))+11);

  return 0;
}
