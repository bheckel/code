int gmodule_two = 2;

void module_two_fn(void) {
	puts("This fn from extern2.c not required to be extern'd b/c it' a fn.");
}


static module_two_staticfn(void) {
	puts("You'll never see this one due to static keyword.");
}
