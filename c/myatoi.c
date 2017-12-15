// Adapted from Steve Summit's C Tutorial.

#include <ctype.h>

int myatoi(char str[]) {
  int i;
  int retval = 0;

  for ( i = 0; str[i] != '\0'; i = i + 1 ) {
    if(!isspace(str[i]))
         break;
    }

  for ( ; str[i] != '\0'; i = i + 1 ) {
    if ( !isdigit(str[i]) )
      break;
    retval = 10 * retval + (str[i] - '0');
    }

  return retval;
}
