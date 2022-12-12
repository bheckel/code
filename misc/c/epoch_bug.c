/*****************************************************************************
 *     Name: epoch_bug.c (originally ch0.time.c)
 *
 *  Summary: Epoch bug calculation.
 *
 *  Adapted: Tue 21 Aug 2001 13:46:19 (Bob Heckel--Deep C Secrets)
 *****************************************************************************
*/
#include <stdio.h>
#include <time.h>

int main(void) {
  /* 01111111 11111111 11111111 11111111 */
  time_t biggest = 0x7FFFFFFF;
  /* 10000000 00000000 00000000 00000000 */
  time_t toobig = biggest + 1;

  printf("epoch bug = %s\n", asctime(gmtime(&biggest)) );
  printf("epoch bug = %s", asctime(gmtime(&toobig)) );
}
