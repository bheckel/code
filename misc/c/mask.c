/*****************************************************************************
 *    Name: mask.c
 *
 * Summary: See p. 521 Waite New C Primer.
 *
 * Created: Tue 15 May 2001 08:27:34 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char **argv) {
  int foo;
  int mask;
 
  /* Binary 1111 1111  Decimal 255 */
  mask = 0377;

  /* Binary 0001 1111 1111  Decimal 511 */
  foo = 0777;
  printf("foo before AND: %d\n", foo);

  /* AND
   * mask leaves the final 8 bits of foo alone and sets the rest to 0.  So
   * regardless of the original size of foo (8, 16, whatever bits), the final
   * value is trimmed to something that fits in a single byte.
   *      Think
   *    _o_paque, not tranparent like 1s
   *      -
   *   0000 1111 1111  mask
   *   0001 1111 1111  foo before
   *   --------------
   *   0000 1111 1111  foo after
   */

  /* foo = foo & mask */
  foo &= mask; 

  printf("foo after AND: %d mask: %d\n", foo, mask);

  /***************************************************************/

  /* OR
   * turns bits on
   */

  /* Binary 1111 0111  Decimal 247 */
  foo = 0367;
  printf("foo before OR: %d\n", foo);

  foo |= mask; 

  printf("foo after OR: %d mask: %d\n", foo, mask);

  return 0;
}
