/*****************************************************************************
 *     Name: getargslist.c
 *
 *  Summary: Read arguments from files.  Good demo of dynamic memory
 *           allocation.  This is a supporting file for getargs.c so
 *           $ gcc -c getargslist.c
 *           $ gcc getargs getargslist.o
 *
 *           Sample call getargs @arg.dat
 *
 *  Adapted: Mon 05 Aug 2002 08:59:39 (Bob Heckel -- Code Capsules)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define CHUNK 10    /* reallocation amount */

static char **args; /* the argument list */
static int nleft;   /* unused argument slots */
static int nargs;   /* number of arguments */

/* Private Functions */
static void expand(FILE *f);
static void add(char *arg);

char **arglist(int old_nargs, char **old_args, int *new_nargs) {
  int i;

  /* Initial Allocation */
  args= calloc(old_nargs,sizeof(char *));
  assert(args);
  nleft = old_nargs;
  nargs = 0;

  /* Process each command-line argument */
  for ( i = 0; i < old_nargs; ++i )
    if ( old_args[i][0] == '@' ) {
      /* Open file of arguments */
      FILE *f = fopen(old_args[i]+1,"r");
      if(f) {
        expand(f);
        fclose(f);
      }
    }
    else
      add(old_args[i]);

  *new_nargs = nargs;

  return args;
}


void free_arglist(int n, char **av) {
  int i;

  for (i = 0; i <n; ++ i)
     free(av[i]);

  free(av);
}

static void expand(FILE *f) {
  char token[BUFSIZ];

  while (fscanf(f,"%s",token) == 1)
     if (token[0] == '@') {
      FILE *g = fopen(token+1,"r");
      if (g) {
        expand(g);
        fclose(g);
       }
     }
    else
      add(token);
}


static void add(char *arg) {
  if (nleft == 0) {
    /* Expand argument list */
    args = realloc(args,(nargs+CHUNK) * sizeof(char *));
    assert(args);
    nleft = CHUNK;
  }

  /* Allocate space for and store argument */
  args[nargs] = malloc(strlen(arg) + 1);
  assert(args[nargs]);
  strcpy(args[nargs++], arg);
  --nleft;
}
