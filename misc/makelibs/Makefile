# Adapted: Mon Sep 13 14:13:57 2004 (Bob Heckel --
#  http://heather.cs.ucdavis.edu/~matloff/UnixAndC/CLanguage/Make.html)

WC: Main.o ReadLine.o WordCount.o UpdateCounts.o PrintLine.o 
	cc -g -o WC Main.o ReadLine.o WordCount.o UpdateCounts.o \
            PrintLine.o 

Main.o: Main.c Defs.h ExternVars.h
	cc -g -c Main.c

ReadLine.o: ReadLine.c Defs.h ExternVars.h
	cc -g -c ReadLine.c

WordCount.o: WordCount.c Defs.h ExternVars.h
	cc -g -c WordCount.c

UpdateCounts.o: UpdateCounts.c Defs.h ExternVars.h
	cc -g -c UpdateCounts.c

PrintLine.o: PrintLine.c Defs.h ExternVars.h
	cc -g -c PrintLine.c

clean:
	rm -f *.o
	rm -f WC
