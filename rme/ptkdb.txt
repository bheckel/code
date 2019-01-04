#############
To install on W2K using ActiveState:

c:\Perl\bin\ppm.exe
> install Tk

From Cygwin:
Unpack Devel-ptkdb-1.107.tar.gz anywhere.
cd Devel-ptkdb-1.107
mkdir ~/perllib_bobh/Devel
cp ptkdb.pm ~/perllib_bobh/Devel

To verify (from Cygwin but using ActiveState's perl):
perla test.pl

I've set up a rat's nest of symlinks and batfiles that allow running like this
from Cygwin:
$ pldebug test.pl


#############
To install to ~ in Linux:

Install Tk to home dir:
Untar Tk....tar.gz to ~/src
perl Makefile.PL PREFIX=~/perllib
make
make test
make install

Untar ptkdb....tar.gz to ~/src
mkdir ~/perllib/lib/site_perl/5.005/i686-linux/Devel
cp ptkdb.pm to ~/perllib/lib/site_perl/5.005/i686-linux/Devel

To run e.g. 
$ perl -d:ptkdb ~/todel/test.pl  (don't have to EXPORT DISPLAY)
