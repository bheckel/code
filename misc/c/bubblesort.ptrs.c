/*-------------------- bubble_1.c --------------------*/

/* Program bubble_1.c from PTRTUT10.HTM   6/13/97 */

#include <stdio.h>

int arr[10] = { 6, 2, 1, 7, 2 };

void bubble(int a[], int n);

int main(void) {
  int i;
  putchar('\n');
  for (i = 0; i < 10; i++) {
    printf("%d ", arr[i]);
  }
  bubble(arr, 10);
  putchar('\n');

  for (i = 0; i < 10; i++) {
    printf("%d ", arr[i]);
  }
  return 0;
}

/* Restricted to integers. */
void bubble(int a[], int n) {
  int i, j, t;
  for (i = n-1; i >= 0; i--) {
    for (j = 1; j <= i; j++) {
      if (a[j-1] > a[j]) {
          t = a[j-1];
          a[j-1] = a[j];
          a[j] = t;
      }
    }
  }
}


