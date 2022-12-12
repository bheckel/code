/*****************************************************************************
 *     Name: struct_sort.c
 *
 *  Summary: Demo of sorting structs with qsort().  Also see int_sort.c 
 *           and string_sort.c
 *
 *           This code is inefficient since most of the time it is faster to
 *           swap pointers than structures (structures tend to be bigger than
 *           pointers).  So look at struct_sort_ptrs.c for a better method
 *           (which unfortunately requires another level of indirection in the
 *           compare function). 
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
  // sizeof this struct is 176, i.e. (16+11+13+4)x4
  static struct person some_people[NELEMS] = {
    {"Lincoln","Abraham","555-1865",161},
    {"Ford","Henry","555-1903",98},
    {"Ford","Edsel","555-1965",53},
    {"Trump","Donald","555-1988",49}
  };
  ///printf("%d", sizeof some_people);

  // Sort by name (last, then first).
  qsort(some_people, NELEMS, sizeof some_people[0], name_comp);

  puts("By name:");
  for ( i=0; i<NELEMS; ++i )
     printf("%s, %s, %s %d\n", some_people[i].last,
                               some_people[i].first,
                               some_people[i].phone,
                               some_people[i].age);

  // Sort by age.
  qsort(some_people, NELEMS, sizeof some_people[0], age_comp);

  puts("\nBy age:");
  for ( i=0; i<NELEMS; ++i )
     printf("%s, %s, %s %d\n", some_people[i].last,
                               some_people[i].first,
                               some_people[i].phone,
                               some_people[i].age);

  return 0;
}


static int name_comp(const void *p1, const void *p2) {
  struct person *sp1 = (struct person *) p1;
  struct person *sp2 = (struct person *) p2;
  int order = strcmp(sp1->last, sp2->last);

  // Handle cases where last names are the same.
  if ( order == 0 ) {
    ///puts(sp1->last);
    // Sort on first name instead.
    order= strcmp(sp1->first, sp2->first);
  }

  return order;
}


static int age_comp(const void *p1, const void *p2) {
  struct person *sp1 = (struct person *) p1;
  struct person *sp2 = (struct person *) p2;

  return sp1->age - sp2->age;
}
