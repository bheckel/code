/*****************************************************************************
 *     Name: sizes_of.c
 *
 *  Summary: Determine sizes of basic data types on this machine.
 *           TODO comma-fy the range values
 *
 *           char, int, float, and double are data types
 *           unsigned, short, and long are specifiers
 *
 *  Created: Tue 24 Jul 2001 16:55:47 (Bob Heckel)
 * Modified: Wed 17 Oct 2001 13:51:36 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <math.h>


int main(int argc, char** argv) {
  ///char unsigned ch;
  char ch;

  puts("For this machine:\n");
  printf("sizeof char is %d\n", sizeof(char));  /* always 1 */

  // %.0f is used for floats *and* doubles.
  printf("char bits range 0 to %.0f\n\n", pow(2,(8*sizeof(char)))-1);

  printf("sizeof int is %d\n", sizeof(int));
  printf("int bits range -%.0f to %.0f\n\n", (pow(2,(8*sizeof(int))))/2,
                                             (pow(2,(8*sizeof(int))))/2-1);

  // int is assumed if specfier is not qualified.
  printf("sizeof short is %d\n", sizeof(short));
  printf("long bits range -%.0f to %.0f\n\n", (pow(2,(8*sizeof(short))))/2,
                                              (pow(2,(8*sizeof(short))))/2-1);

  printf("sizeof long is %d\n", sizeof(long));
  printf("long bits range -%.0f to %.0f\n\n", (pow(2,(8*sizeof(long))))/2,
                                              (pow(2,(8*sizeof(long))))/2-1);

  printf("sizeof float is %d\n", sizeof(float));
  printf("float bits range -%.0f to %.0f\n\n", (pow(2,(8*sizeof(float))))/2,
                                               (pow(2,(8*sizeof(float))))/2-1);

  printf("sizeof double is %d\n", sizeof(double));
  printf("double bits range -%.0f to %.0f\n\n", (pow(2,(8*sizeof(double))))/2,
                                              (pow(2,(8*sizeof(double))))/2-1);

  printf("There is no such thing as a short double.\n\n");

  printf("sizeof long double is %d\n", sizeof(long double));
  printf("long double bits range -%.0f to %.0f\n\n", 
                                         (pow(2,(8*sizeof(long double))))/2,
                                         (pow(2,(8*sizeof(long double))))/2-1);

  #ifdef DEBUGGING
  // Test wrapping of signed char:
  ch = 1;
  while ( ch != 0 )
    printf("will wrap after 127 %d\n", ch++);
  #endif
  

  return 0;
}
