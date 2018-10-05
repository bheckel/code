
B back

Esc+b  show bookmarks
Esc+a  add bookmarks
s      show buffers

---

From now on see readme.cygw3m.txt for maintainer info

-----

2010-11-28 
Need setup.exe's ncurses, libgc, gettext dev libs (at least)

./configure --with-ssl --with-termlib-ncurses --enable-image=no

Full would be:

./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib \
  --localstatedir=/var --datadir=/usr/share --mandir=/usr/share/man \
  --infodir=/usr/share/info --with-termlib=ncurses --enable-image=no

but not sure it works - better:
./configure --with-ssl --with-termlib=ncurses --enable-image=no --prefix=$HOME/projects/w3m/inst/


cygwin libgc1 libintl8 libncurses10 libopenssl098 zlib0


-----

2005-12-23 

: 1rsh86800@zebwd044; ll ~/.w3m/
total 14
-rw-r--r--  1   63 Feb 25  2005 bookmark.html
-rw-r--r--  1   52 Mar  8  2005 bufinfo
lrwxrwxrwx  1   38 Nov 23 09:14 config -> /home/bheckel/code/misccode/config.w3m
-rw-r--r--  1 2563 May 22  2005 cookie
-rw-r--r--  1 6999 Nov 29 16:53 history
lrwxrwxrwx  1   38 Nov 23 09:15 keymap -> /home/bheckel/code/misccode/keymap.w3m

-----

2005-11-17 after reverting to cygwin 1.3.10, compiled libgc, w/o changes, first (see
readme.libgc.txt) then compiled openssl-0.9.7e.tar.gz (may have needed the dev
version but won't be using this for web, only local browsing).



2005-05-23 daeb: confused as to how I got image support on buddha, can't get
X11 support on daeb -

  ar: x11/x11_w3mimg.o not found
  *** Error code 1
  make: Fatal error: Command failed for target `w3mimg.a'
  Current working directory /home/bheckel/src/w3m-0.5.1/w3mimg
  *** Error code 1
  make: Fatal error: Command failed for target `w3mimg/w3mimg.a'

but don't care so did this:

compile/install gc:
normal ./configure (no opt paths)

compile/install w3m:
export LDFLAGS='-Xlinker -R/usr/local/lib'  # not sure if matters
./configure --prefix=/opt --enable-image=no

then

cdc$ scp config.w3m bheckel@daeb:.w3m/
cdc$ scp keymap.w3m bheckel@daeb:.w3m/
and rename/edit

-----


Avoid 'long long' configure error:
export LDFLAGS='-Xlinker -R/opt/lib'
./configure --PREFIX=/opt --with-gc=/opt


-----


# Run a CGI script without a server
w3m -o cgi_bin=~/public_html/cgi-bin/ file:/cgi-bin/cgi_template.pl


-----


Quote pasted from http://www.sic.med.tohoku.ac.jp/~satodai/w3m-dev-en/ :

  Here are the steps I did (my system is Mandrake 10.1 Community):

  from http://www.hpl.hp.com/personal/Hans_Boehm/gc/
  I downloaded the package gc.tar.gz 
  and copied it into the ~/tmp dir. Then,
  # urpmi gcc
  $ cd ~/tmp
  $ tar xzvf gc.tar.gz
  $ cd gc6.3
  $ ./configure
  $ make
  $ make check
  # make install

  . I downloaded the package openssl-0.9.7e.tar.gz 
  and copied into my ~/tmp dir. Then,
  $ cd ~/tmp
  $ tar xzvf openssl-0.9.7e.tar.gz
  $ cd openssl-0.9.7e
  $ ./config
  $ make
  $ make test
  # make install

  . From http://prdownloads.sourceforge.net/w3m/ 
  I downloaded the package w3m-0.5.1.tar.gz
  and copied it into the ~/tmp dir. Then,

  ###$ export LDFLAGS="-Xlinker -R/usr/local/lib"
  $ cd ~/tmp
  $ tar xzvf w3m-0.5.1.tar.gz
  $ cd w3m-0.5.1
  $ ./configure
  $ make
  # make install
