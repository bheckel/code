/*****************************************************************************
 *     Name: time_brokendown.c
 *
 *  Summary: Demo of extracting elements from the tm date struct.
 *
 * Adapted: Tue 04 Dec 2001 12:56:35 (Bob Heckel -- 
 *                                            Al Bowers (abowers@gate.net))
 *****************************************************************************
*/
#include <stdio.h>
#include <time.h>

// int tm_sec;    /* seconds after the minute (0 to 61) */
// int tm_min;    /* minutes after the hour (0 to 59) */
// int tm_hour;   /* hours since midnight (0 to 23) */
// int tm_mday;   /* day of the month (1 to 31) */
// int tm_mon;    /* months since January (0 to 11) */
// int tm_year;   /* years since 1900 */
// int tm_wday;   /* days since Sunday (0 to 6 Sunday=0) */
// int tm_yday;   /* days since January 1 (0 to 365) */
// int tm_isdst;  /* Daylight Savings Time */

int main(void) {
   time_t now;
   struct tm *t;  // used as pointer to tm struct

   now = time(NULL);

   if ( now !=  (time_t)-1 ) {
     // Declaration:  struct tm *localtime(const time_t *timer); 
     t = localtime(&now);
     printf("In localtime, month is %d, day is %d and year is %d.\n",
                                 t->tm_mon+1, t->tm_mday, t->tm_year+1900);
   } else {
     puts("Time is not available.");
   }

   return 0;
}

