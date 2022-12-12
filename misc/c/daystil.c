/*****************************************************************************
 *     Name: daystil.c
 *
 *  Summary: Calculate days in a date range.
 *
 *           Std Library's difftime() may also have solved this problem.
 *
 *           TODO allow 5/21/1998 instead of 5 21 1998
 *
 *  Adapted: Fri 30 Nov 2001 08:45:20 (Bob Heckel Tim Behrendsen tim@a-sis.com)
// Modified: Mon 17 Nov 2008 10:23:03 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define IS_LEAP(y) ((y) % 4) == 0 && (! ((y) % 100) == 0 || ((y) % 400) == 0)

// Year must be full four-digit year.
unsigned long CalcDays(int month, int day, int year) {
  unsigned long days;
  static int DaysAtMonth[] = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};

  //   (days in year) + (leap days) + (this year) + (this month)
  days = (year * 365) + (year / 4) - (year / 100) + (year / 400) + DaysAtMonth[month-1] + day;

  return((month < 3 && IS_LEAP(year)) ? days - 1 : days);
} 


int main(int argc, char *argv[]) {
  int start, end, days;
  time_t now;
  struct tm *t;  // used as pointer to tm struct

  // 1 == no params; 4 == want default to now; 7 == start & end provided
  switch ( argc ) {
    case 4:
      now = time(NULL);
      if ( now !=  (time_t)-1 ) {
        // Declaration:  struct tm *localtime(const time_t *timer); 
        t = localtime(&now);
        start = CalcDays(t->tm_mon+1, t->tm_mday, t->tm_year+1900);
        end = CalcDays(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]));
      } else {
        puts("Time is not available.  Exiting.");
        exit(__LINE__);
      }
      break;
    case 7:
      // E.g. CalcDays(12, 3, 2001);
      start = CalcDays(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]));
      end = CalcDays(atoi(argv[4]), atoi(argv[5]), atoi(argv[6]));
      break;
    default:
      fprintf(stderr,"usage: %s [startmo day yr]  endmo day yr\n", argv[0]);
      fprintf(stderr,"       e.g. daystil 5 21 1998\n");
      exit(__LINE__);
      break;
  }

  days = end - start;
  printf("%d", days);

  return 0;
}
