/*****************************************************************************
 *     Name: hook_ternary.c
 *
 *  Summary: Demo the hook operator
 *
 *  Adapted: Sat 23 Mar 2002 18:58:42 (Bob Heckel -- Chuck Allison Thinking 
 *                                     in C++ CDROM)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  int x = 1;
  int y = 2;
  int max;
  
  ///max = (x > y ? x : y);
  max = x > y ? x : y;   // more obscure
  printf("max is %d\n", max);

  return 0;
}
