//////////////////////////////////////////////////////////////////////////////
//     Name: nested_structs.cpp
//
//  Summary: Nested structs and pointers to structs.
//           For some reason won't compile as C code...
//
//  Adapted: Mon 07 Jan 2002 18:29:28 (Bob Heckel --
//                         http://www.cplusplus.com/doc/tutorial/tut3-4.html)
//////////////////////////////////////////////////////////////////////////////
#include <stdio.h>

struct movies_t {
  char *title;
  int   year;
};

struct friends_t {
  // TODO couldn't get name[50] to work (not necessarily an improvement)...
  char    *name;
  char    *email;
  movies_t favourite_movie;
};


int main(void) {
  friends_t  charlie;
  friends_t  maria;
  friends_t *pfriends = &charlie;

  charlie.name = "chuck";
  maria.favourite_movie.title = "blade runner";
  charlie.favourite_movie.year = 1983;

  printf("charlie.name: %s\n", charlie.name);
  printf("maria.favourite_movie: %s\n", maria.favourite_movie);
  // These two are the same.
  printf("charlie.favourite_movie.year: %d\n", charlie.favourite_movie.year);
  printf("pfriends->favourite_movie.year: %d\n", pfriends->favourite_movie.year);

  return 0;
}
