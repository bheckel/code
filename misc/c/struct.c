/*****************************************************************************
 *     Name: struct.c
 *
 *  Summary: Demo of structures in C.
 *
 *  Created: Sun 08 Aug 2004 21:41:25 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  struct {
    int i;
    char c;
  } mytag1;  // variable of the new structure type (optional)

  struct TagA {  // structure tag (optional)
    int i;
    char c;
  } mytag2;

  // Must use keyword 'struct' unless did a typedef earlier.
  struct TagA mytaglater;

  struct TagB {
    int i;
    char c;
  } mytag3, mytag4;



  mytag1.i = 1;
  printf("%d", mytag1.i);

  mytag2.i = 2;
  printf("%d", mytag2.i);

  mytaglater.i = 3;
  printf("%d", mytaglater.i);

  return 0;
}
