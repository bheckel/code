
/* Program 5.1 from PTRTUT10.HTM     6/13/97 */


#include <stdio.h>
#include <string.h>

struct tagbobh {
  char lname[20];
  char fname[20];
  int age;
};

struct tagbobh my_struct;           /* Declare the structure my_struct. */
void show_name(struct tagbobh *p);  /* Function prototype. */

int main(void) {
  /* Terse and potentially confusing. */
  /*** struct tagbobh *st_ptr = &my_struct; ***/
  /* So try this instead: */
  /* Declare a pointer to a structure. */
  struct tagbobh *st_ptr;
  /* Point pointer to address of my_struct. */
  st_ptr = &my_struct;

  printf("Using strcpy:\n");
  strcpy(my_struct.lname, "Jensen");
  strcpy(my_struct.fname, "Ted");
  printf("\n%s ", my_struct.fname);
  printf("%s\n\n\n", my_struct.lname);

  my_struct.age = 63;
  /* Pass the pointer to struct. */
  show_name(st_ptr);
  return 0;
}

/* p is declared a pointer. */
void show_name(struct tagbobh *p) {
  printf("Using pointer to struct:\n");
  /* p points to structure. */
  printf("\n%s ", p->fname);
  /* Same thing, value at address p */
  printf("%s ", (*p).lname);
  printf("%d\n", p->age);
}

