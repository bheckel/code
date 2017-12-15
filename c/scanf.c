#include <stdio.h>

/* Get user input. */
int main(void) {
  int x;
  float y;

  puts("Enter a float, then an int" );

  scanf("%f %d", &y, &x);

  printf("\nYou entered %f and %d", y, x );

  return 0;
}
