/*****************************************************************************
 *     Name: append_string.c
 *
 *  Summary: We want to append $y to the end of $x. In C, this is extremely 
 *           tricky. In Perl, you would do this:
 *
 *           $x = 'foo';     
 *           $y = 'bar';
 *           $x .= $y;    # the dot-equals operator
 *
 *  Adapted: Thu 07 Aug 2003 13:17:38 (Bob Heckel -- 
 *                         http://www.perl.com/pub/a/2001/06/27/ctoperl.html)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
  char* x = "foo";
  char* y = "bar";
        
  char* tmp = malloc(strlen(x) + strlen(y) + 1);

  strcpy(tmp, x);
  strcat(tmp, y);
  x = tmp;

  puts(x);

  return 0;
}
