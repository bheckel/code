/* Demonstrates passing a pointer to a multidimensional */
/* array to a function. */
/*  Adapted: Thu 19 Jul 2001 19:12:27 (Bob Heckel -- InformIT) */

#include <stdio.h>

void printarray_1(int (*ptr)[4]);
void printarray_2(int (*ptr)[4], int n);

int main(void) {
  int  multi[3][4] = { { 1, 2, 3, 4 },
                     { 5, 6, 7, 8 },
                     { 9, 10, 11, 12 } };

  /* ptr is a pointer to an array of 4 ints. */
  int (*ptr)[4], count;

  /* Set ptr to point to the first element of multi. */
  ptr = multi;

  /* With each loop, ptr is incremented to point to the next */
  /* element (that is, the next 4-element integer array) of multi. */
  for (count = 0; count < 3; count++)
      printarray_1(ptr++);

  puts("\n\nPress Enter...");
  getchar();
  printarray_2(multi, 3);
  printf("\n");
  return(0);
}

void printarray_1(int (*ptr)[4]) {
  /* Prints the elements of a single four-element integer array. */
  /* p is a pointer to type int. You must use a type cast */
  /* to make p equal to the address in ptr. */
  int *p, count;
  p = (int *)ptr;

  for (count = 0; count < 4; count++)
      printf("\n%d", *p++);
}

void printarray_2(int (*ptr)[4], int n) {
  /* Prints the elements of an n by four-element integer array. */
  int *p, count;
  p = (int *)ptr;

  for (count = 0; count < (4 * n); count++)
      printf("\n%d", *p++);
}
