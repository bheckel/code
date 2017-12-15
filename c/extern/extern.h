// Inclusion guard:
#ifndef EXTERN_H
#define EXTERN_H

// These extern declarations do not create the data; that must be done in the
// definition (there is only 1 definition allowed).
//
// extern means "something is defined elsewhere, go find it"
//
// Not required (but not an error either) for functions.
extern int gmodule_one;

// Required b/c extern.c defines gmodule_two which is in turn used by
// extern_main.c
extern int gmodule_two;

#endif
