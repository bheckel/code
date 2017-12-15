/*****************************************************************************
 *     Name: define_preproc.c
 *
 *  Summary: Demo of C macro preprocessor capabilities and dangers.
 *
 *  Adapted: Tue 16 Oct 2001 08:51:00 (Bob Heckel -- Beej's Network Sockets)
// Modified: Wed 24 Mar 2004 13:35:16 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

// Symbolic constants:
// Everything to the right of the identifier (e.g. F(x)) is replaced with
// replacement text.  This is why  #define PI = 3.14  will probably fail when
// resolved as '= 3.14'
// Warning: no data type checking is performed.
#define F(x) (x + 1)
#define FLOOR(a,b) a>=b?0:1
#define FLOOR2(a,b) ((a)>=(b)?0:1)
#define CEILING(a,b) a>b?a:b
// Must use all parens! -- not using the outer can cause a precedence problem,
// not using the (c) ones can cause a problem if CUBE(2+1) is called.
#define CUBE(c) ((c)*(c)*(c))

// TODO why not working??
#define ASSERT(condition, msg) {                  \
  if ( !(condition) ) {                           \
    fprintf(STDERR, "Assertion %s failed: %s\n",  \
                    #condition, msg);             \
    exit(EXIT_FAILURE);                           \
  }                                               \
}

#ifdef FLOOR
  int floorisdef = 42;
#endif

#ifndef FLOOR
  int floornotdef = 66;
#endif

#ifndef VIVIFY
#define VIVIFY "alive!"
#endif

// Conditional if then else:
#define FOO 101

#if FOO > 102
#undef FOO
#define FOO 42
#elif FOO > 100
#undef FOO
#define FOO 3
#endif

#define HELLO(x) printf(#x);

// TOKENCONCAT(O, K) becomes OK
#define TOKENCONCAT(x, y) x ## y


int main(void) {
  int i = 1;

  // Looks like a function.
  printf("F macro: %d\n", F(2));
  // Strangely enough, this also works.
  ///printf("F macro: %d\n", F (2));

  HELLO(\nbob heck\n\n);

  // Will occasionally not work due to precedence rules.  Use parenthesized
  // version.
  printf("FLOOR macro (should ret 1) %d\n", FLOOR(5, 9));
  printf("FLOOR macro (should ret 0) %d\n", FLOOR(9, 5));
  printf("FLOOR2 macro better (should ret 1) %d\n", FLOOR2(5, 9));
  printf("FLOOR2 macro better (should ret 0) %d\n", FLOOR2(9, 5));

  printf("CEILING macro (should ret 9) %d\n", CEILING(9, 5));
  printf("CEILING macro (should ret 9) %d\n", CEILING(5, 9));

  printf("#ifdef FLOOR (should ret 42) %d\n", floorisdef);

  printf("#ifdef VIVIFY (should ret alive!) %s\n", VIVIFY);

  printf("#if FOO (should ret 3) %d\n", FOO);

  printf("cubism: %d\n", CUBE(2+1));

  #if 0
    printf("this is commented out, change to 1 to uncomment it");
  #endif

  // The #line directive allows us to control the line numbers within the code
  // files and the file name that we want that it appears when an error takes
  // place.
  //
  // Crash.  However, it destroys vim's :make
  // $ gcc define_preproc.c
  // boom: In function `main':
  // boom:67: parse error before `int'
  // Toggle these two to test #line
  ///#line 66 "boom"
  ///int a?syntax?error;

  // Abort the compilation process, returning the error that is specified as
  // a parameter.
  #define NOVASCOTIA 1993   // toggle to test
  #ifndef NOVASCOTIA
  #error "Not there now"
  #endif

  // Predefined symbolic constants:
  printf("%d\n", __LINE__);
  printf("%s\n", __FILE__);
  printf("%s\n", __DATE__);
  printf("%s\n", __TIME__);

  ASSERT(i==1, "uh oh");

  return 0;
}
