/*****************************************************************************
 *     Name: write_struct.c
 *
 *  Summary: Demo of writing structs to file.
 *
 *  Adapted: Fri, 22 Dec 2000 19:24:00 (Bob Heckel -- from New C Primer Plus
 *                                      Prata p. 494)
 * Modified: Mon 22 Oct 2001 10:14:17 (Bob Heckel -- direct assignment to
 *                                     structs)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>

#define MAXTIT 40
#define MAXAUT 40
#define MAXBKS  3

/* Set up template. */
struct bookstruct {
  char title[MAXTIT];
  char author[MAXAUT];
  float value;
};


int main(void) {
  /* Array of structs. */
  struct bookstruct mylibr[MAXBKS];

  int    count = 0;
  int    index;
  int    filecount;
  FILE  *pbooks;
  int    size = sizeof(struct bookstruct);

  /* Assign directly to a struct.  Use this form to initialize an *array* of
   * structs:  
   * struct mylibr[MAXBKS] = { {"title1", "auth1", 66.01}, {"title2", "auth2", 66.02} }; 
   */
  struct bookstruct the_bkstruct = { "my_title", "my_auth", 42.66 };

  printf("Testing direct assignment before we get started %.3f %s\n\n", 
                                                         the_bkstruct.value,
                                                         the_bkstruct.author);


  if ( (pbooks = fopen("junk.dat", "a+b")) == NULL ) {
    fputs("Can't open junk.dat\n", stderr);
    exit(1);
  }

  rewind(pbooks);
  while ( count < MAXBKS && fread(&mylibr[count], size, 1, pbooks) == 1 ) {
    if ( count == 0 )
      puts("Current contents:");

    printf("%s by %s: $%.2f\n", mylibr[count].title,
                                mylibr[count].author,
                                mylibr[count].value);
    count++;
  }

  filecount = count;
  if ( count == MAXBKS ) {
    fputs("The junk.dat file is full\n", stderr);
    exit(2);
  }

  puts("Enter new title, enter a blank line to stop.");
  while ( count < MAXBKS && gets(mylibr[count].title) != NULL
          && mylibr[count].title[0] != '\0' ) {
    puts("Now enter author");
    gets(mylibr[count].author);
    puts("Now enter value");
    scanf("%f", &mylibr[count++].value);
    while ( getchar() != '\n' )
      continue;
    if ( count < MAXBKS )
      puts("Enter next title");
  }

  puts("Here are your bks");
  for ( index=0; index<count; index++ )
    printf("%s by %s: $%.2f\n", mylibr[index].title,
                                mylibr[index].author,
                                mylibr[index].value);
  /* Go to end of file. */
  fseek(pbooks, 0L, SEEK_END);
  fwrite(&mylibr[filecount], size, count-filecount, pbooks);
  fclose(pbooks);

  return 0;
}
