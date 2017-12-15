/*****************************************************************************
 *     Name: ptr_assigned_value.c
 *
 *  Summary: Demo of using a pointer as an lvalue.
 *
 *  Adapted: Sat 23 Feb 2002 10:00:08 (Bob Heckel--C++ From the Ground Up
 *                                     Herbert Shildt)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  int *p, num;
  
  ///num = 99;
  p = &num;
  // Works identically and don't need to do the  num = 99;  line
  // "At the address pointed to by p, assign the value 99"
  *p = 99;

  printf("%d\n", num);
  (*p)++;
  printf("%d\n", num);
  (*p)--;
  printf("%d\n", num);

  return 0;
}
