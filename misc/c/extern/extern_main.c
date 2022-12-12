#include <stdio.h>
#include "extern.h"

// Compile via:  $ gcc -c extern.c && gcc extern.o extern_main.c

int main(void) {
  int gmodule_one; // also declared 'extern int gmodule_one' in extern.h 

	gmodule_one = 66;

  puts("in main()");

  // Surprise!  gmodule_two pops into existence via the extern.h inclusion.
	printf("By default, I can always see vari gmodule_two %d\n", gmodule_two);
  // Now override the default which is '2'.
	gmodule_two = 42;

	module_two_fn();  // defined in extern.c
	// Won't work.  Not globally visible b/c declared 'static' in extern.c
	///module_two_staticfn();

	printf("By default, I can always see vari gmodule_two %d\n", gmodule_two);
	
	return 0;
}


void modone_fn(void) {
  puts("This fn is visible in all modules.  It exists in module one");
}
