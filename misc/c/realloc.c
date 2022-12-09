/* Using realloc() to change memory allocation. */
/* Adapted: Wed 25 Jul 2001 11:18:21 (Bob Heckel -- from InformIT) */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  char buf[80], *message;

   /* Input a string. */
   puts("Enter a line of text.");
   gets(buf);
   printf("Length of buf is %d\n", strlen(buf)+1);

   /* Allocate the initial block and copy the string to it. */
   /* message is a memory location into which the user's string is copied. */
   /* This works the same as malloc since the first param (pointer arg) is
    * NULL. */
   message = realloc(NULL, strlen(buf)+1);
   strcpy(message, buf);

   /* Display the message. */
   puts(message);

   /* Get another string from the user. */
   puts("Enter another line of text.");
   gets(buf);
   printf("Now length of buf is %d\n", strlen(buf)+1);

   /* Since message is only big enough to hold the first string, increase the
    * allocation (ie realloc), then concatenate the string to it. */
   message = realloc(message,(strlen(message) + strlen(buf)+1));
   strcat(message, buf);

   /* Display the new message. */
   puts(message);
   return(0);
 }
