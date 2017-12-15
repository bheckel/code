/*****************************************************************************
 *     Name: fstrcmp_test.c
 *
 *  Summary: Harness for fstrcmp.c testing.
 *
 *  Created: Sun 25 Aug 2002 09:57:59 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include "fstrcmp.h"

int main(int argc, char *argv[]) {
  float ret;

  ///ret = fstrcmp("teststr", "testy str", 0.8); 
  ///ret = fstrcmp("teststr", "x tessttr", 0.9); 
  ///ret = fstrcmp("teststr", "tessttr", 0.9); 
  ret = fstrcmp("testing string transposition", 
                "testing string transpsoition", 0.9); 
  ///ret = fstrcmp("teststr", "teststr", 0.9); 
  printf("result: %f\n", ret);

  return 0;
}
