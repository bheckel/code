/*****************************************************************************
 *     Name: leapyear.c
 *
 *  Summary: Determine if year is a leap year.
 *
 *  Adapted: Mon 08 Jul 2002 16:21:43 (Bob Heckel -- freshsources.com)
 *****************************************************************************
*/
#include <stdio.h>

inline int isleap(int y) { return y%4 == 0 && y%100 != 0 || y%400 == 0;};

int main(int argc, char *argv[]) {
  if ( isleap(2000) ) {
    puts("year is a leap year");
  } else {
    puts("year is a not leap year");
  }

  return 0;
}
