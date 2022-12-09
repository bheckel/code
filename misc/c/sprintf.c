/*****************************************************************************
 *     Name: sprintf.c
 *
 *  Summary: Secure use of sprintf that avoids buffer overflows.
 *
 *           Take a look at asprintf if you keep dumping core from
 *           miscalculation the required buffer size.
 *
 *  Adapted: Wed 22 Aug 2001 08:23:45 (Bob Heckel--Secure-Programs-HOWTO)
 *****************************************************************************
*/
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  char buf[] = "a secured string";
 
  // The precision specification specifies the maximum length that that
  // particular string may have in its output when used as a string conversion
  // specifier - and thus it can be used to protect against buffer overflows. 
  // sprintf(buf, "%*s",  sizeof(buf)-1, "long-string");  /* WRONG */
  sprintf(buf, "%.*s", sizeof(buf)-1, buf);               /* RIGHT */
  // If the code were changed so that ``buf'' was a *pointer* to some allocated
  // memory, then all ``sizeof()'' operations would have to be changed (or
  // sizeof would just measure the size of a pointer, which isn't enough space
  // for most values).
 
  printf("here is %s", buf);
 
  return 0;
}
