/*****************************************************************************
 *     Name: itobs.c
 *
 *  Summary: Demo of bit fiddling.  Integer to binary string.
 *
 *  Adapted: Sat, 30 Dec 2000 19:14:37 (Bob Heckel -- New C Primer Plus around
 *                                      p. 524)
 *****************************************************************************
*/

#include <stdio.h>

char * itobs(int, char *);
/* TODO */
///char * makereadable(char *);
int invert_end(int, int);

int main() {
  int dec_str;
  char * x;
  char * y;
  char bin_str[8*sizeof(int)+1];

  puts("Enter decimal integer (q to quit):");
  while ( scanf("%d", &dec_str) == 1 ) {
    x = itobs(dec_str, bin_str);
    ///y = makereadable(x);
    ///puts(y);
    ///printf("%d is %s\n", dec_str, itobs(dec_str, bin_str));
    printf("%d is %s\n", dec_str, x);
    printf("inverting last 4 bits %s:\n", 
                                  itobs(invert_end(dec_str,4), bin_str));
  }
    
  return 0;
}


char * itobs(int n, char * ps) {
  int i;
  static int size = 8*sizeof(int);

  for ( i=size-1; i>=0; i--, n>>=1 )
    /*     octal          */
    ps[i] = (01 & n) + '0';
    ///printf("yyz: %d", ps[i]);

  ps[size] = '\0';
  return ps;
}


int invert_end(int num, int bits) {
  int mask = 0;
  int bitval = 1;

  while ( bits-- > 0 ) {
    mask |= bitval;
    bitval <<= 1;
  }

  return num ^ mask;
}


/* TODO how to insert blanks every 4 chars for 0000 0100 0001 ... output? */
char * makereadable(char * strin) {
  ///char * p;
  ///char * q;
  ///int i;

 ///p = strin; 
 
 ///p[3] = 'z';
   ///for ( p = strin, i=0; *p != '\0'; p++, i++ ) {
     ///if ( i % 4 ) { 
       ///puts(p);
     ///} 
   ///}

  ///return q;
}
