/* See Makefile in this directory. */
#include <stdio.h>
#include "makedemo_a.h"
#include "makedemo_2.c"
#include "makedemo_3.c"


int main() {
  extern void fn_two();
  extern void fn_three();
  fn_two();
  fn_three();
  puts("Goodbye from makedemo_main.c\n");
  exit(0);
}
