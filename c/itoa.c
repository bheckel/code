/*****************************************************************************
 *     Name: itoa.c
 *
 *  Summary: Integer to ASCII.  More importantly, a good explanation of
 *           tossing around arrays.
 *
 *  Adapted: Fri 02 Aug 2002 08:27:18 (Bob Heckel -- Steve Summit tutorial
 *                                     Chapter 19)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>  // for malloc()

#define BUFSIZE 10

// Returning a pointer to a static array is a practical and popular solution
// to the problem of ``returning'' an array, but it has one drawback. Each
// time you call the function, it re-uses the same array and returns the same
// pointer. Therefore, when you call the function a second time, whatever
// information it ``returned'' to you last time will be overwritten. (More
// precisely, the information, that the function returned a pointer to, will
// be overwritten.)
//
// Use this when it's unlikely that the caller will be trying to call multiple
// times and retain multiple return values.
char *itoa1(int n) {
  static char retbuf[BUFSIZE];

  sprintf(retbuf, "%d", n);

  return retbuf;
}


// If the function can't use a local or local static array to hold the return
// value, the next option is to have the caller allocate an array, and use
// that. In this case, the function accepts one additional argument - a
// pointer to the location to write the result back to. 
char * itoa2(int n, char buf[]) {
  sprintf(buf, "%d", n);

  return buf;
}


// When the limit of a single static return array within the function would be
// unacceptable, and when it would be a nuisance for the caller to have to
// declare or otherwise allocate return arrays, a third option is for the
// function to dynamically allocate some memory for the returned array by
// calling malloc. 
char *itoa3(int n, int memrequest) {
  char *retbuf = malloc(memrequest);    // request space on the heap

	if ( retbuf == NULL ) {
		fprintf(stderr, "out of memory\n");
		exit(1);
  }

  sprintf(retbuf, "%d", n);

  return retbuf;
}


int main(void) {
  char approach2buf[10];
  char *approach3p;

  printf("integer %d\n", 97);
  printf("character %c\n", 97);

  // 1.  Single call (assumes BUFSIZE has been defined):
  printf("ASCII string itoa1: %s\n", itoa1(97));

  // 2.  Have caller pass an array buffer.
  printf("ASCII string itoa2: %s\n", itoa2(97, approach2buf));

  // 3a.  OK for multiple calls.  Require nothing of the caller.
  // Sloppy, memory in retbuf is never reclaimed.
  printf("ASCII string itoa3 one approach: %s\n", itoa3(97, 10));

  // 3b.  OK for multiple calls.  Require nothing of the caller.
  approach3p = itoa3(97, 10);
  // Better but requires the caller to know about the func internals and
  // remember to free().
  printf("ASCII string itoa3 another approach: %s\n", approach3p);
  // Memory in retbuf *is* reclaimed.
  free(approach3p);

  return 0;
}
