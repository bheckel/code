/*****************************************************************************
 *     Name: link_mathlib.c
 *
 *  Summary: Demo of a safe C prog that links to the math library (located in
 *           /lib with filename libm.so.6 which is a symlink to libm-2.1.3.so
 *           on Linux boxes).
 *
 *          Compile:
 *            gcc -Wall -g -o a link_mathlib.c -lm
 *
 *  Adapted: Fri 30 Jan 2004 16:06:01 (Bob Heckel --
 *           http://www.debian.org/doc/manuals/reference/ch-program.en.html)
 *****************************************************************************
*/
#include <stdio.h>
#include <math.h>
#include <string.h>

int main(int argc, char **argv, char **envp){
  double x;
  char y[11];

  x=sqrt(argc+7.5);
  strncpy(y, argv[0], 10);  /* prevent buffer overflow */
  y[10] = '\0';             /* fill to make sure string ends with '\0' */
  printf("%5i, %5.3f, %10s, %10s\n", argc, x, y, argv[1]);

  return 0;
}
