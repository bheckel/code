##############################################################################
# Demo of a simple makefile for a dummy project.
#
# Place makedemo_main.c, makedemo_2.c, makedemo_3.c and this file in a
# directory, then run make, make install, make clean.
#
# Reference use --
#   $? is list of prerequisites changed more recently than current target.
#   $@ is name of current target.
#   $< is name of current prerequisite
#   $* is name of current prerequisite, without suffix
# 
# Adapted: Tue, 26 Dec 2000 14:46:27 (Bob Heckel -- Beginning Linux
#                                     Programming p.295)
##############################################################################

all: makedemo

CC = gcc
INSTDIR = /home/bheckel/tmp
INCLUDE = .
CFLAGS = -g -Wall -ansi
MYLIB = makedemo_mylib.a

# Calling make or make makedemo is the same.
makedemo: makedemo_main.o $(MYLIB)
	$(CC) -o makedemojunk makedemo_main.o $(MYLIB)

$(MYLIB): $(MYLIB)(makedemo_2.o) $(MYLIB)(makedemo_3.o)

makedemo_main.o: makedemo_main.c makedemo_a.h

makedemo_2.o: makedemo_2.c makedemo_a.h makedemo_b.h

makedemo_3.o: makedemo_3.c makedemo_b.h makedemo_c.h

install: makedemojunk
	@if [ -d $(INSTDIR) ]; then \
       cp makedemojunk.exe $(INSTDIR); \
       echo "Installed in $(INSTDIR)"; \
     else \
       echo "Failed to install.  Directory $(INSTDIR) doesn't exist"; \
     fi;

clean:
	-rm makedemojunk.exe makedemo_main.o makedemo_2.o makedemo_3.o $(MYLIB)
