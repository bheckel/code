/*****************************************************************************
 *     Name: typedef_struct.c
 * 
 *  Summary: Using typedef with struct.
 *
 *           typedef creates synonyms (aliases) for previously defined data
 *           types.  No new data types are created.
 *
 *           Macro-like e.g.:
 *                    real  fake
 *           typedef Card* CardPtr  
 *           defines the word CardPtr as a synonym for Card*
 *
 *           Alternatively, this e.g. lets 'Filter' stand for the whole thing:
 *           typedef void (*Filter)(FILE *fp, char *fn);
 *           (see file:///C:/cygwin/home/bqh0/code/c/c_eskimo/int/sx10a.html
 *            or better 
 *            file:///C:/cygwin/home/bqh0/code/c/c_eskimo/int/sx4fa.html)
 *
 *  Adapted: Wed 17 Oct 2001 10:24:57 (Bob Heckel -- Thinking in C++)
 * Modified: Sat 22 Mar 2003 12:18:02 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

// Traditional approach.
struct Structure1 {
  char c;
  int i;
  float f;
  double d;
};

// Better.  Everything from this line to the closing curly is represented by
// the word 'Structure2' from now on.
typedef struct Structure2 { // also works if 'Structure2' is not included here,
  char c;                   // I think the common approach is to skip it here
  int i;
  float f;
  double d;
} Structure2;


int main(void) {
  // Traditional approach requires the struct keyword.
  struct Structure1 s1a, s1b;
  // Better.  Pretend Structure2 is a built-in type like int or float when you
  // define s2a and s2b.
  Structure2 s2a, s2b;   // easier
  // Pointer example.
  ///Structure2 *sp = &s2a;   // more compact but harder to grok so don't use
  Structure2* sp;        
  sp = &s2a;

  s1a.c = 'a';
  s1a.i = 1;
  s1a.f = 3.14;
  s1a.d = 0.00093;
  s1b.c = 'b';
  s1b.i = 2;
  s1b.f = 4.14;
  s1b.d = 0.00094;

  s2a.c = 'c';
  s2a.i = 3;
  s2a.f = 5.14;
  s2a.d = 0.00095;
  s2b.c = 'd';
  s2b.i = 4;
  s2b.f = 6.14;
  s2b.d = 0.00096;

  printf("Structure1 float %f\n", s1a.f);
  printf("Structure2 float %f\n", s2a.f);
  printf("Structure2 ptr float %f\n", sp->f);

  return 0;
} 
