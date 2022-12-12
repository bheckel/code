// Inclusion guard:
#ifndef EXTERN_H
#define EXTERN_H
#include "extern.h"
#endif


int main(void) {
  int gmodule_one;
  int hidden_one;  // not in extern.h

	gmodule_one = 66;  // declared in header file as well
	gmodule_two = 42;  // declared in header file as well

  puts("in main()");
	module_two_fn();  // defined in extern2.c
	// Not globally visible b/c declared 'static' in extern2.c
	///module_two_staticfn();
	printf("By default, I can always see vari gmodule_two %d", gmodule_two);
	
	return 0;
}


void modone_fn(void) {
  puts("This fn is visible in all modules.  It exists in module one");
}
