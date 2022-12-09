/*****************************************************************************
 *     Name: environment.c
 *
 *  Summary: Obtain and set environment variable values.
 *
 *  Adapted: Tue 10 Apr 2001 09:23:50 (Bob Heckel --
 *                             http://www.whitefang.com/unix/faq_2.html#SEC2)
 * Modified: Tue Jul 09 11:06:11 2002 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>

int setit(char *setme);
int getit(char *getme);


int main(void) {
  getit("TERM");
  setit("MYVAR");
  getit("MYVAR");

  return 0;
}


// This env vari does not export.
int setit(char *setme) {
  static char envbuf[256];

  sprintf(envbuf, "%s=%s", setme, "the_value");

  if ( putenv(envbuf) ) {
    printf("Sorry, putenv() couldn't find the memory for %s\n",envbuf);
  } else {
    printf("Env var set successfully.\n");
  }

  return 0;
}


int getit(char *getme) {
  char *getenv(const char *name);
  char *envvar;

  envvar = getenv(getme);

  printf("The value for the environment variable %s is ", getme);

  if ( envvar ) {
    printf("%s\n",envvar);
  } else {
    printf("Error: not set.\n");
  }

  return 0;

}
