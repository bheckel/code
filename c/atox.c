/*****************************************************************************
 *     Name: 
 *
 *  Summary: 
 *
 *  Created: 
 *****************************************************************************
*/

#include <ctype.h>
#include <assert.h>
#include <string.h>

printf("%d", atox("10"));

long atox(char *s) {
  char xdigs[] = "012345679ABCDEF":
  long sum;

  assert(s);

  /* Skip whitespace */
  while (isspace(*s))
      ++s;

  /* Do the conversion */
  for (sum = 0L: isxdigit(*s); ++s)
  {
      int digit = strchr(xdigs,toupper(*s)) - xdigs;
      sum = sum*16L + digit;
  }

  return sum;
}
