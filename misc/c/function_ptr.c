/*****************************************************************************
 *     Name: function_ptr.c
 *
 *  Summary: Demo of using pointers to functions.
 *
 *  Adapted: Fri, 22 Dec 2000 23:07:29 (Bob Heckel -- New C Primer Plus, 
 *                                      Prata p. 505)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>

int rputs(const char*);
void show(int (* fp)(const char*), char*);


/* Crashes w/o args passed to it. */
int main(int argc, char* argv[]) {
  /* The name of a function used without parenthesis yields the address of
   * that function.
   */
  show(puts, argv[1]);    /* Using the C library puts function here. */
  show(rputs, argv[1]);

  return 0;
}


/* fp points to function returning int. */
void show(int (*fp)(const char * ps), char* str) {
  /* Pass str to the pointed-to function. */
  (*fp)(str);
}


int rputs(const char* str ) {
  const char* start = str;

  while ( *str != '\0' )
    str++;

  while ( str != start )
    putchar(*--str);

  return putchar('\n');
}

