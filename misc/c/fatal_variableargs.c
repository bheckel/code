/*****************************************************************************
 *     Name: fatal_variableargs.c
 *
 *  Summary: Exit program with an error message and demo variable number of 
 *           arguments.
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

void fatal(char *fmt, ...) {
  va_list args;
 
  if ( fmt != NULL && strlen(fmt) > 0 ) {
    va_start(args,fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
  }

///  exit(EXIT_FAILURE);
}


int main(void) {
  int x = 88;

  fatal("looks like an f-up\n");  
  fatal("looks like a %d style f-up", x);  

  return 0;
}
