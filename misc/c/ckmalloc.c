// One way to think about chkmalloc is that it centralizes the test on
// malloc's return value. Another way of thinking about it is that it is a
// special, alternate version of malloc that never returns NULL. (The fact
// that it never returns NULL does not mean that it never fails, but just that
// if/when it does fail, it signifies this by calling exit instead of
// returning NULL.) Aborting the entire program when a call to malloc fails
// may seem draconian, and there are programs (e.g. text editors) for which it
// would be a completely unacceptable strategy, but it's fine for our
// purposes, especially if it doesn't happen very often. (In any case,
// aborting the program cleanly with a message like ``Out of memory'' is still
// vastly preferable to crashing horribly and mysteriously, which is what
// programs that don't check malloc's return value eventually do.) 

#include <stdio.h>
#include <stdlib.h>
#include "chkmalloc.h"

void *
chkmalloc(size_t sz)
{
void *ret = malloc(sz);
if(ret == NULL)
	{
	fprintf(stderr, "Out of memory\n");
	exit(EXIT_FAILURE);
	}
return ret;
}
