# Target: Prerequisite(s)
#     TAB Shell Command

CC = gcc

# Linking only here.  gcc will call ld and save us some work.
WCpgm: Main.o ReadLine.o WordCount.o UpdateCounts.o PrintLine.o 
	$(CC) -g -o WC Main.o ReadLine.o WordCount.o UpdateCounts.o \
	    PrintLine.o 

Main.o: Main.c Defs.h ExternVars.h
	$(CC) -g -c Main.c

ReadLine.o: ReadLine.c Defs.h ExternVars.h
	$(CC) -g -c ReadLine.c

WordCount.o: WordCount.c Defs.h ExternVars.h
	$(CC) -g -c WordCount.c

UpdateCounts.o: UpdateCounts.c Defs.h ExternVars.h
	$(CC) -g -c UpdateCounts.c

PrintLine.o: PrintLine.c Defs.h ExternVars.h
	$(CC) -g -c PrintLine.c

clean:
	-rm *.o
