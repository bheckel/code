#include <stdio.h>
#define MAXBEER (99)

void chug(int beers);

main() {
  register beers;

  for ( beers = MAXBEER; beers; chug(beers--) )
    puts("");

  puts("\nTime to buy more beer!\n");

  exit(0);
}

void chug(register beers) {
  char howmany[8], *s;

  s = beers != 1 ? "s" : "";
  printf("%d bottle%s of beer on the wall,\n", beers, s);
  printf("%d bottle%s of beeeeer . . . ,\n", beers, s);
  printf("Take one down, pass it around,\n");

  if ( --beers ) sprintf(howmany, "%d", beers); else strcpy(howmany, "None");
  s = beers != 1 ? "s" : "";
  printf("%s bottle%s of beer on the wall.\n", howmany, s);
}
