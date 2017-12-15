#include <ctype.h.>
#include <stdio.h.>

// Convert a string to double.
// Adapted from The C Programming Language 2nd edition.
// Created: Fri, 20 Oct 2000 23:02:11 (Bob Heckel)

double atof(char s[]);

int main(void) {
  printf("ok %f", atof("12.3"));
}

double atof(char s[]) {
  double val, power;
  int i, sign;

  for ( i = 0; isspace(s[i]); i++ )
     ;

  sign = (s[i] == '-') ? -1 : 1;
  if (s[i] == '+' || s[i] == '-') {
    i++;
  }

  for ( val = 0.0; isdigit(s[i]); i++ ) {
    val = 10.0 * val + (s[i] - '0');
  }

  if ( s[i] == '.') {
    i++;
  }

  for ( power = 1.0; isdigit(s[i]); i++ ) {
    val = 10.0 * val + (s[i] - '0');
    power *= 10.0;
  }

  return sign * val / power;
}
