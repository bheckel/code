/*****************************************************************************
*     Name: debug_preprocessor.c
* 
*  Summary: Demo of using preprocessor debugging flags.
*
*                   Debugging: $ gcc -DDEB debug_preprocessor.c
*                   when done: $ gcc debug_preprocessor.c
*
*  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
*****************************************************************************
*/
#include <stdio.h>

#ifdef DEB
#define FIVE 5
#endif

int main(void) {
  int x;

  #ifdef DEB
  printf("debugging in progress %d", FIVE);
  #else
  printf("not debugging");
  #endif

  return 0;
} 
