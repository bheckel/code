// Inclusion guard:
#ifndef EXTERN_H
#include "extern.h"
#define EXTERN_H
#endif

int gmodule_two;
int hidden_two;  // not in extern.h

void module_two_fn(void) {
	puts("This fn from extern2.c not required to be extern'd b/c it' a fn.");
}


static module_two_staticfn(void) {
	puts("You'll never see this one due to static keyword.");
}
