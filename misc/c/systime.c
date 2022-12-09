/*****************************************************************************
 *     Name: systime.c
 *
 *  Summary: Print Unix epoch time since 1/1/1970.  
 *           Faster than
 *           $ perl -e 'print time, "\n"'
 *           or
 *           $ date +%s
 *
 *  Adapted: Fri 29 Aug 2003 10:29:45 (Bob Heckel -- Unix Review)
 *****************************************************************************
*/
#include <stdio.h>
#include <time.h>

int main(void) {
  printf("%ld\n", (long)time((time_t *)0));
  return 0;
}
