/*****************************************************************************
 *     Name: getargs.c
 *
 *  Summary: Read arguments from files (recursively).  Good demo of 
 *           dynamic memory allocation.
 *
 *           Sample call getargs @arg.dat
 *
 *           The arglist function returns a pointer to a dynamically-sized,
 *           ragged array of strings, which is the fully-expanded list of
 *           program arguments. The function free_args frees all of the memory
 *           used in the creation of the array. 
 *
 *           arglist() uses calloc to dynamically allocate an array large
 *           enough to hold argc-1 arguments, the original number of arguments
 *           on the command line. arglist calls add to insert a new argument
 *           into the list. If the array is full, add calls realloc to
 *           increase the size of the array by a predetermined amount (CHUNK).
 *           add calls malloc to place all argument strings on the heap. The
 *           function expand() processes indirect file arguments. Since
 *           indirect files can be nested, expand is a recursive function. If
 *           there are no indirect file arguments, then realloc never gets
 *           called. 
 *
 *  Adapted: Mon 05 Aug 2002 08:59:39 (Bob Heckel -- Code Capsules Dynamic
 *                                     Memory)
 *****************************************************************************
*/
#include <stdio.h>

extern char**arglist(int,char**,int *);
extern void free_arglist(int,char **);

int main(int argc, char *argv[]) {
  int i, nargs;
  char **args = arglist(--argc,++argv,&nargs);

  for (i = 0; i < nargs; ++i)
    printf("%d: %s\n",i,args[i]);

  free_arglist(nargs,args);

  return 0;
}
