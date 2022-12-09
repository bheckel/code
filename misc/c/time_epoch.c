/*****************************************************************************
 *     Name: time_epoch.c
 *
 *  Summary: Demo of obtaining seconds since The Epoch.
 *
 *  Created: Tue 04 Dec 2001 12:54:32 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <time.h>

int main(int argc, char *argv[]) {
  time_t currtime;

  currtime = time(NULL);
  printf("seconds since Epoch: %d\n", currtime);

  return 0;
}

