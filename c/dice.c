
/*****************************************************************************
 *    Name: 
 *
 * Summary:  DOESNT WORK. WHY??
 *
 * Created: 
 *****************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

main() {
  printf("%d", (int)(rand() / (RAND_MAX + 1.0) * 3) + 1);
}
