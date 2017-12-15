/*****************************************************************************
 *     Name: rtrim.c
 *
 *  Summary: Demo of removing spaces from end of a string array.
 *
 *  Adapted: Mon 05 Aug 2002 15:55:25 (Bob Heckel -- usenet posts)
 *****************************************************************************
*/
#include <stdio.h>
#include <ctype.h>

char * rtrim(char *s){
  char *res = s;
  char *end = s;

  while( *s )
    if ( !isspace(*(s++)) )
      end=s;

  *end = '\0';

  return(res);
}


char * rtrim2(char *s) {
  int x = 0, y = 0;

  while( s[x] ) {
    if(!isspace(s[x]))
      y = x;
    x = x + 1;
  } s[y]= '\0';

  return(s);
}


int main(void) {
  // inputstr is a pointer to a string literal, also called a string constant.
  // You are supplying inputstr as an argument to rtrim where you modify the
  // string.  ANSI C prohibits the modification of string literals. The
  // behavior of a program that  attempts to alter a string literal is
  // undefined. The solution in this program is to change s from a char
  // pointer to a string literal into a char * to an array of characters.
  ///char *inputstr = "miles to go before I sleep  "; 
  char inputstr[] = "miles to go before I sleep  "; 

  printf("before:xxx%sxxx\n", inputstr);
  ///rtrim(inputstr);
  rtrim2(inputstr);
  printf("after:yyy%syyy\n", inputstr);

  return 0;
}
