/*****************************************************************************
 *     Name: struct_sort_ptrs.c
 *
 *  Summary: Demo of sorting structs with qsort().  Also see int_sort.c,
 *           string_sort.c and struct_sort.c
 *
 *           This code is more efficient than struct_sort.c since most of the
 *           time it is faster to swap pointers than structures (structures
 *           tend to be bigger than pointers).
 *
 * Adapted: Sat 29 Jun 2002 21:56:51 (Bob Heckel -- Code Capsules Chuck
 *                                    Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NELEMS 4

struct person {
  char last[16];
  char first[11];
  char phone[13];
  int  age;
};

static int name_comp(const void *, const void *);
static int age_comp(const void *, const void *);


int main(void) {
  size_t i;
  static struct person some_people[NELEMS] = {
    {"Lincoln","Abraham","555-1865",161},
    {"Ford","Henry","555-1903",98},
    {"Ford","Edsel","555-1965",53},
    {"Trump","Donald","555-1988",49}
  };
  struct person *some_ptrs[NELEMS] = {
    some_people,
    some_people+1,
    some_people+2,
    some_people+3
  };

  // Same call as struct_sort.c
  qsort(some_ptrs, NELEMS, sizeof some_ptrs[0], name_comp);

  puts ("By name:");
  for ( i=0; i<NELEMS; ++i )
     printf("%s, %s, %s %d\n", some_ptrs[i]->last,
                               some_ptrs[i]->first,
                               some_ptrs[i]->phone,
                               some_ptrs[i]->age);

  // Same call as struct_sort.c
  qsort(some_ptrs, NELEMS, sizeof some_ptrs[0], age_comp);

  puts("\nBy age:");
  for ( i=0; i<NELEMS; ++i )
     printf("%s, %s, %s %d\n", some_ptrs[i]->last,
                               some_ptrs[i]->first,
                               some_ptrs[i]->phone,
                               some_ptrs[i]->age);

  return 0;
}


// These next 2 functions are passed to qsort()

// It's more efficient to pass qsort an array of pointers to structures (like
// this) than to pass it an array of actual structures.
static int name_comp(const void *p1, const void *p2) {
  // Additional level of indirection, not needed in struct_sort.c, is required
  // here.
  struct person *sp1 = * (struct person **) p1;
  struct person *sp2 = * (struct person **) p2;
  int order = strcmp(sp1->last,sp2->last);

  if ( order == 0 )
     order = strcmp(sp1->first,sp2->first);

  return order;
}


// It's more efficient to pass qsort an array of pointers to structures (like
// this) than to pass it an array of actual structures.
static int age_comp(const void *p1, const void *p2) {
  // Additional level of indirection, not needed in struct_sort.c, is required
  // here.
  struct person *sp1 = * (struct person **) p1;
  struct person *sp2 = * (struct person **) p2;

  return sp1->age - sp2->age;
}
