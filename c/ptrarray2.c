/*
 *****************************************************************************
 *    *(*(multi + row) + col)    and
 *    multi[row][col]            yield the same results.
 *
 * The following program illustrates this using integer arrays instead of
 * character arrays. 
 *****************************************************************************
 */

/* Adapted from Program 6.1 from PTRTUT10.HTM   6/13/97*/

#include <stdio.h>
#define ROWS 2
#define COLS 4

int multi[ROWS][COLS];

int main(void) {
  int row, col;
  for (row = 0; row < ROWS; row++) {
    for (col = 0; col < COLS; col++) {
      multi[row][col] = row + col;
    }
  }

  for (row = 0; row < ROWS; row++) {
    for (col = 0; col < COLS; col++) {
      printf("\n%d is product of adding row plus col  ", multi[row][col]);
      printf(" Compare %d ",*(*(multi + row) + col));
    }
  }

  return 0;
}
