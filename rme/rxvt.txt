For HP-UX
/opt/rxvt/bin/rxvt -cr 10 -pr 12 -sr
For Cygwin:
C:\cygwin\opt\rxvt.exe -geometry 80x35+370+255  -fn "Andale Mono-14" -bg black -fg white -sr -sl 450 -cr green -e bash


DIDNT (WONT) WORK 12/29/00 B/C SOLECTRON HASNT PURCH THE X DEV LIBS.
For HPUX (use hpLdev01):
As software:
  cp rxvt-2.6.3.tar.gz ~software/src/tarballs/clean
  cd ~software/src
  gunzip tarball/clean/rxvt-2.6.3.tar.gz
  tar xvf tarballs/clean/rxvt-2.6.3.tar
  gzip tarball/clean/rxvt-2.6.3.tar


Many distributions come with rxvt, but don't have it set up right for allowing
colors from all apps that support them. If you type echo $TERM from an rxvt,
and it says xterm you should consider doing the following.  First get a
tarball of rxvt from the rxvt ftp site. 

Once you have untarred it, 
  cp rxvt-x.x.x/doc/etc/rxvt.terminfo /usr/share/lib/terminfo/r/rxvt 

Then append rxvt-x.x.x/doc/etc/rxvt.termcap to /etc/termcap 

The only thing left to do is compile and install rxvt. 
  ./configure --with-term=rxvt --prefix=/opt
as this tells rxvt that it will be running as rxvt not as xterm (which is
default).

  make
  make -n install      # to preview make
  make install

and then try to open a new rxvt (be sure you run it from the right spot, which
is most likely /usr/local/bin/rxvt not wherever /usr/X11R6/bin/rxvt or
wherever the one shipped with your distribution was placed) When you run rxvt,
if everything was done right you should be able to type echo $TERM and have it
display rxvt. 
