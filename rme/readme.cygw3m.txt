28-Apr-13

cygport w3m-0.5.3-1.cygport prep
copy README to dist/CYGWIN-PATCHES/
cygport ... compile
cygport ... install
cygport ... package
tar cfj w3mdist.bz2
scp w3mdist.bz2 bheckel@sdf.org:html/cygwin/w3m64/

---

26-Apr-13 not working
export CFLAGS=-mcmodel=medium

---

31-Oct-12 - TODO don't want compface for w3m only (non w3m-img) installs right??

---

25-Oct-12

$ ls -R ~/src
/home/rsh86800/src:
0532cygport  w3m.README  w3m-img.README

/home/rsh86800/src/0532cygport:
bug_555467_FTBFS.patch        w3m-0.5.1-gcc4.patch  w3m-0.5.3-2.cygport
bug_566101_Fix-DSO-X11.patch  w3m-0.5.3.tar.gz

w3m.README:
###
    w3m
    ------------------------------------------

    Text mode WWW browser/pager

    A text-based web browser as well as a pager like 'more' or 'less'.
    With w3m you can browse web pages through a terminal emulator 
    window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
    formatting tool which typesets HTML into plain text."

    Runtime requirements:
      libgc1
      libintl8
      libncursesw10
      libopenssl100
      perl
      zlib0
      compface

    Build requirements:
      libncurses-devel
      libgc-devel
      openssl-devel
      zlib-devel

    Canonical homepage:
      http://sourceforge.net/projects/w3m

    Canonical download:
      http://sourceforge.net/projects/w3m/files/

    License:
      MIT License

    Language:
      C

    ------------------------------------

    Build instructions:
      unpack w3m-x.x.x-x-src.tar.bz2
        if you use setup to install this src package, it will be unpacked 
        under /usr/src automatically
      cd /usr/src
      tar xfj w3m-x.x.x-x-src.tar.bz2

    This will create:
      /usr/src/w3m-x.x.x-x.patch
      /usr/src/w3m-x.x.x-x-src.tar.bz2

    To find out the files included in the binary distribution, you can
    use "cygcheck -l w3m", or browse the listing for the appropriate version
    at http://cygwin.com/packages/.

    ------------------

    Port Notes:

    ----------  w3m-0.5.3-2 -- 2012-10-25 -----------
    Repackage to adjust permissions and cleanup to address cygcheck-related
    issues on certain client installations.

    ----------  w3m-0.5.3-1 -- 2012-10-08 -----------
    New upstream release.

    ----------  w3m-0.5.2-2 -- 2011-01-11 -----------
    Bugfix to avoid crash when LANG is unset.

    ----------  w3m-0.5.2-1 -- 2010-12-03 -----------
    New upstream release.

    ----------  w3m-0.5.1-2 -- 2007-03-30 -----------
    Linked against openssl098 instead of the deprecated openssl097.

    ----------  w3m-0.5.1-1 -- 2005-04-15 -----------
    Initial release.


    For more information about this package, see the upstream documentation in
    /usr/share/doc/w3m

    Cygwin port maintained by: Bob Heckel <bheckel at gmail.com>
    Please address all questions to the Cygwin mailing list at <cygwin at cygwin.com>
###

w3m-img.README:
###
    w3m-img
    ------------------------------------------

    Text mode WWW browser (inline image support for X)

    A text-based web browser as well as a pager like 'more' or 'less'.
    With w3m you can browse web pages through a terminal emulator 
    window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
    formatting tool which typesets HTML into plain text."

    Runtime requirements:
      libgc1
      libintl8
      libncursesw10
      libopenssl100
      perl
      zlib0
      compface
      libgdk_pixbuf2.0_0
      libgdk_pixbuf_xlib2.0_0
      libglib2.0_0
      libX11_6
      ImageMagick
      w3m

    Build requirements:
      libncurses-devel
      libgc-devel
      openssl-devel
      zlib-devel
      libgdk_pixbuf-devel

    Canonical homepage:
      http://sourceforge.net/projects/w3m

    Canonical download:
      http://sourceforge.net/projects/w3m/files/

    License:
      MIT License

    Language:
      C

    ------------------------------------

    Build instructions:
      see w3m.README

    To find out the files included in the binary distribution, you can use 
    "cygcheck -l w3m", "cygcheck -l w3m-img" or browse the listing for the 
    appropriate version at http://cygwin.com/packages/.

    ------------------

    Port Notes:

    ----------  w3m-img-0.5.3-2 -- 2012-10-25 -----------
    Repackage to adjust permissions and cleanup to address cygcheck-related
    issues on certain client installations.


    ----------  w3m-img-0.5.3-1 -- 2012-10-08 -----------
    First inclusion of w3m inline image support as a Cygwin package.


    For more information about this package, see the upstream documentation in
    /usr/share/doc/w3m

    Cygwin port maintained by: Bob Heckel <bheckel at gmail.com>
    Please address all questions to the Cygwin mailing list at <cygwin at cygwin.com>
###

$ cd ~/src/0532cygport
$ cygport w3m-0.5.3-2.cygport prep && cygport w3m-0.5.3-2.cygport compile && cygport w3m-0.5.3-2.cygport install && cygport w3m-0.5.3-2.cygport package

---

http://pkgs.fedoraproject.org/cgit/w3m.git/plain/bug_555467_FTBFS.patch

--- main.c.old	2007-05-31 06:49:50.000000000 +0530
+++ main.c	2010-02-16 16:16:24.000000000 +0530
@@ -842,7 +842,9 @@
     mySignal(SIGPIPE, SigPipe);
 #endif
 
-    orig_GC_warn_proc = GC_set_warn_proc(wrap_GC_warn_proc);
+    orig_GC_warn_proc = GC_get_warn_proc();
+    GC_set_warn_proc(wrap_GC_warn_proc);
+
     err_msg = Strnew();
     if (load_argc == 0) {
 	/* no URL specified */

patch --dry-run -Np0 -i main.c.patch

---

xTODO remove xdg shit !!!
xTODO add external: to hints !!!
03-Oct-12
First cygport version.  Using Yaakov's w3m-0.5.3-1.cygport unedited.

Used \w3m-0.5.3-1\log\w3m-0.5.3-1-compile.log frequently

Installed glib-2.0 gdk-pixbuf2-wmf libgdk_pixbuf_xlib2.0-devel based on failures and package search on cygwin.com 

w3m-0.5.3-1.cygport:
###############
CATEGORY="Web"
SUMMARY="Text-mode web browser"
DESCRIPTION="w3m is a text-based web browser as well as a pager like
'more' or 'less'. With w3m you can browse web pages through a terminal
emulator window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
formatting tool which typesets HTML into plain text."
HOMEPAGE="http://w3m.sourceforge.net/"
SRC_URI="mirror://sourceforge/w3m/${P}.tar.gz"

PKG_NAMES="w3m w3m-img"
w3m_REQUIRES="compface xdg-utils"
w3m_CONTENTS="--exclude=w3mimg* usr/"
w3m_img_SUMMARY="${SUMMARY} (inline image support)"
w3m_img_REQUIRES="ImageMagick w3m"
w3m_img_CONTENTS="usr/lib/w3m/w3mimg*"

PATCH_URI="
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/bug_555467_FTBFS.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/bug_566101_Fix-DSO-X11.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/rh707994-fix-https-segfault.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/w3m-0.4.1-helpcharset.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/w3m-0.5.1-gcc4.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/w3m-0.5.2-ssl_verify_server_on.patch
http://pkgs.fedoraproject.org/cgit/w3m.git/plain/w3m-0.5.2-fix_gcc_error.patch
"

NO_AUTOHEADER=1
CYGCONF_ARGS="
	--enable-image=x11 --with-imagelib=gtk2
	--with-browser=xdg-open --with-mailer=xdg-email
	--with-charset=UTF-8
"
###############

$ history
748  2012-10-03 14:17:53 cygport
749  2012-10-03 14:14:19 cygport w3m-0.5.3-1.cygport prep
750  2012-10-03 14:14:31 cygport w3m-0.5.3-1.cygport compile
752  2012-10-03 14:17:59 cygport w3m-0.5.3-1.cygport test  # not needed
753  2012-10-03 14:18:07 cygport w3m-0.5.3-1.cygport install
755  2012-10-03 14:18:36 cygport w3m-0.5.3-1.cygport package

>>> w3m requires: libgc1 libintl8 libncursesw10 libopenssl100 perl zlib0 compface xdg-utils
>>> w3m-img requires: libgdk_pixbuf2.0_0 libgdk_pixbuf_xlib2.0_0 libglib2.0_0 libX11_6 ImageMagick w3m

$ startxwin
$ urxvt
$ w3m ~/code/html/image.html
$ time w3m -dump ~/code/misccode/bashref2_05.html >/dev/null

real    0m0.981s
user    0m0.405s
sys     0m0.218s


top setup.hint:
==============
category: Web Text
requires: libgc1 libintl8 libncursesw10 libopenssl100 perl zlib0 compface xdg-utils
sdesc: "text-based web browser and pager"
ldesc: "w3m is a text-based web browser as well as a pager like
'more' or 'less'. With w3m you can browse web pages through a terminal
emulator window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
formatting tool which typesets HTML into plain text."


img setup.hint:
==============
category: Web Text X11 Gnome
requires: libgdk_pixbuf2.0_0 libgdk_pixbuf_xlib2.0_0 libglib2.0_0 libX11_6 ImageMagick w3m
sdesc: "text-based web browser and pager - inline image support for X"
ldesc: "w3m-img provides some utilities to support inline images for w3m on 
terminal emulator in X Window System environments and Linux framebuffer"


debug setup.hint:
================
category: Debug
requires: cygwin-debuginfo
sdesc: "Debug info"
ldesc: "This package contains files necessary for debugging the w3m package 
with gdb"

/usr/share/doc/Cygwin/w3m.README:
#################################
w3m
------------------------------------------

Text mode WWW browser/pager

A text-based web browser as well as a pager like 'more' or 'less'.
With w3m you can browse web pages through a terminal emulator 
window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
formatting tool which typesets HTML into plain text."

Runtime requirements:
  libgc1
  libintl8
  libncursesw10
  libopenssl100
  perl
  zlib0
  compface
  xdg-utils

Build requirements:
  libncurses-devel
  libgc-devel
  openssl-devel
  zlib-devel

Canonical homepage:
  http://sourceforge.net/projects/w3m

Canonical download:
  http://sourceforge.net/projects/w3m/files/

License:
  MIT License

Language:
  C

------------------------------------

Build instructions:
  unpack w3m-0.5.3-1-src.tar.bz2
    if you use setup to install this src package, it will be unpacked under /usr/src automatically
  cd /usr/src
  tar xfj w3m-0.5.3-1-src.tar.bz2

This will create:
  /usr/src/w3m-0.5.3-1.patch
  /usr/src/w3m-0.5.3-1-src.tar.bz2

To find out the files included in the binary distribution, you can
use "cygcheck -l w3m", or browse the listing for the appropriate version
at http://cygwin.com/packages/.

------------------

Port Notes:

----------  w3m-0.5.3-1 -- 2012-10-08 -----------
New upstream release.

----------  w3m-0.5.2-2 -- 2011-01-11 -----------
Bugfix to avoid crash when LANG is unset.

----------  w3m-0.5.2-1 -- 2010-12-03 -----------
New upstream release.

----------  w3m-0.5.1-2 -- 2007-03-30 -----------
Linked against openssl098 instead of the deprecated openssl097.

----------  w3m-0.5.1-1 -- 2005-04-15 -----------
Initial release.
Thanks to Jason Tishler for his valuable assistance in testing and debugging
performance issues.


For more information about this package, see the upstream documentation in
/usr/share/doc/w3m
#################################

/usr/share/doc/Cygwin/w3m-img.README:
#################################
w3m-img
------------------------------------------

Text mode WWW browser (inline image support for X)

A text-based web browser as well as a pager like 'more' or 'less'.
With w3m you can browse web pages through a terminal emulator 
window (xterm, rxvt, etc.). Moreover, w3m can be used as a text
formatting tool which typesets HTML into plain text."

Runtime requirements:
  libgc1
  libintl8
  libncursesw10
  libopenssl100
  perl
  zlib0
  compface
  xdg-utils
  libgdk_pixbuf2.0_0
  libgdk_pixbuf_xlib2.0_0
  libglib2.0_0
  libX11_6
  ImageMagick
  w3m

Build requirements:
  libncurses-devel
  libgc-devel
  openssl-devel
  zlib-devel
  libgdk_pixbuf-devel

Canonical homepage:
  http://sourceforge.net/projects/w3m

Canonical download:
  http://sourceforge.net/projects/w3m/files/

License:
  MIT License

Language:
  C

------------------------------------

Build instructions:
  see w3m.README

To find out the files included in the binary distribution, you can use 
"cygcheck -l w3m", "cygcheck -l w3m-img" or browse the listing for the 
appropriate version at http://cygwin.com/packages/.

------------------

Port Notes:

----------  w3m-img-0.5.3-1 -- 2012-10-08 -----------
First inclusion of w3m inline image support as a Cygwin package.


For more information about this package, see the upstream documentation in
/usr/share/doc/w3m

#################################


DONT PUT [ANNOUNCEMENT] IN EMAIL SUBJECT LINE!!!!!!!


---

23-May-12 0.5.3 in progress (need libgc so did cyginstall $c/install/libgc-devel-7.1-1.tar.bz2 first)

cd w3m-0.5.2

mkdir .inst

./configure --prefix=/home/rsh86800/w3m_cygwin/w3m-0.5.3/.inst/usr --libexecdir=/home/rsh86800/w3m_cygwin/w3m-0.5.3/.inst/usr/lib --with-ssl --with-termlib=ncurses --with-imagelib=imlib2

make

# but images still not working with w3mimgthing.exe so removve the -with-imagelib part to avoid unused dependencies

./configure --prefix=/home/rsh86800/w3m_cygwin/w3m-0.5.3/.inst/usr --libexecdir=/home/rsh86800/w3m_cygwin/w3m-0.5.3/.inst/usr/lib --with-ssl --with-termlib=ncurses

24-MAY-12 STOPPING TO UPGRADE LIBGC WILL NEED TO START OVER
24-MAY-12 STOPPING TO UPGRADE LIBGC WILL NEED TO START OVER
24-MAY-12 STOPPING TO UPGRADE LIBGC WILL NEED TO START OVER

---

w3m 0.5.2:

0 rsh86800@ZEBWL10D43164 w3m-0.5.3/ Wed May 23 14:00:05  
$ time w3m -dump ~/code/misccode/bashref2_05.html >/dev/null

real    0m1.188s
user    0m0.359s
sys     0m0.046s
0 rsh86800@ZEBWL10D43164 w3m-0.5.3/ Wed May 23 14:00:08  
$ time w3m -dump ~/code/misccode/bashref2_05.html >/dev/null

real    0m1.547s
user    0m0.358s
sys     0m0.092s
0 rsh86800@ZEBWL10D43164 w3m-0.5.3/ Wed May 23 14:00:11  
$ time w3m -dump ~/code/misccode/bashref2_05.html >/dev/null

real    0m1.234s
user    0m0.296s
sys     0m0.062s

---

2011-01-10 0.5.2-2 LANG bug crash fix

Do binary:
---------
git checkout -a fixlang2
vi terms.c
cd w3m-0.5.2
mkdir .inst
git add .
git commit -m 'ready for compiling'
git checkout -a compiled
# Real config - lied about in w3m.README
./configure --prefix=/home/bheckel/projects/w3m/w3m-0.5.2/.inst/usr \
  --libexecdir=/home/bheckel/projects/w3m/w3m-0.5.2/.inst/usr/lib --with-ssl \
  --with-termlib=ncurses --enable-image=no 
make && make install
cd .inst
find . -name "*.dll" -or -name "*.exe" | xargs -r strip
mkdir -p usr/share/doc/Cygwin
cp foo/w3m.README usr/share/doc/Cygwin/w3m-0.5.2-1.README (or better? w3m.README)
mkdir -p usr/share/doc/w3m-0.5.2/ 
cp ../{ABOUT-NLS,ChangeLog,NEWS,README,TODO} usr/share/doc/w3m-0.5.2/
tar cvfj w3m-0.5.2-2.tar.bz2 usr/  #<--binary is done, can rm old build dir
cd ..
git add .
git commit -m 'binary built'

cd 'C:\Users\bheckel_2\Downloads\'
tar tvfj w3m-0.5.2-1.tar.bz2>|/tmp/1
tar tvfj ./.inst/w3m-0.5.2-2.tar.bz2>|/tmp/2
vi -d /tmp/{1,2}

sha1sum ./.inst/w3m-0.5.2-2.tar.bz2


Do source:
---------
cd /tmp
mkdir 0522
cd 0522
tar xfz /home/bheckel/projects/w3m/w3m-0.5.2.tar.gz 
mv w3m-0.5.2/ w3m-0.5.2-2
tar xfz /home/bheckel/projects/w3m/w3m-0.5.2.tar.gz 
mkdir -p w3m-0.5.2-2/CYGWIN-PATCHES
st
cp /home/bheckel/projects/w3m/w3m-0.5.2/terms.c /tmp/0522/w3m-0.5.2-2/
diff -Nrup w3m-0.5.2/ w3m-0.5.2-2/ >w3m-0.5.2-2.patch
tar cfj w3m-0.5.2-2-src.tar.bz2 w3m-0.5.2-2.patch w3m-0.5.2-2/

cp -i w3m-0.5.2-2-src.tar.bz2 /home/bheckel/install
cd /home/bheckel/install
tar tvfj /home/bheckel/install/w3m-0.5.2-1-src.tar.bz2 >|3
tar tvfj w3m-0.5.2-2-src.tar.bz2 >|4
vi -d 3 4

sha1sum /tmp/0522/w3m-0.5.2-2-src.tar.bz2


Upload:
------
scp /home/bheckel/projects/w3m/w3m-0.5.2/.inst/w3m-0.5.2-2.tar.bz2 \
    /tmp/0522/w3m-0.5.2-2-src.tar.bz2  bheckel@sdf.org:html/cygwin/w3m/

cd /home/bheckel/install

wget -x -nH --cut-dirs=1 \
http://bheckel.sdf.org/cygwin/w3m/w3m-0.5.2-2-src.tar.bz2 \
http://bheckel.sdf.org/cygwin/w3m/w3m-0.5.2-2.tar.bz2

sha1sum w3m/w3m-0.5.2-2.tar.bz2 w3m-0.5.2-2-src.tar.bz2
66095adbe6ebc9e26bfa302c76d13a1a09626fd9 *w3m/w3m-0.5.2-2.tar.bz2
5d04f2df81785d677c516ed9ff26bb1dd3795ada *w3m-0.5.2-2-src.tar.bz2


RFU email
Announce email


---
2010-12-04 0.5.2-1

http://sourceforge.net/projects/w3m/files/w3m/w3m-0.5.2/w3m-0.5.2.tar.gz/download

edit CYGWIN-PATCHES.hold/*


Do binary:
---------
mkdir ~/ciw3m  # for make install

tar xvf ...

./configure --prefix=/home/bheckel/ciw3m/usr --sysconfdir=/home/bheckel/ciw3m/etc --libexecdir=/home/bheckel/ciw3m/usr/lib --localstatedir=/home/bheckel/ciw3m/var --datadir=/home/bheckel/ciw3m//usr/share --mandir=/home/bheckel/ciw3m/usr/share/man --infodir=/home/bheckel/ciw3m/usr/share/info --with-termlib=ncurses --enable-image=no

make && make install

cd ~/ciw3m

find . -name "*.dll" -or -name "*.exe" | xargs -r strip

# Find runtime dependencies for w3m-0.5.2-1.README (stolen from gbs.sh)
find . -name "*.exe" -o -name "*.dll" | xargs -r cygcheck | \
  sed -ne '/^  [^ ]/ s,\\,/,gp' | sort -bu | \
  xargs -r -n1 cygpath -u | xargs -r cygcheck -f | sed 's%^%  %' | sort -u

mkdir -p usr/share/doc/Cygwin

cp /home/bheckel/src/cygwin_w3m/CYGWIN_PATCHES.hold/w3m.README /home/bheckel/ciw3m/usr/share/doc/Cygwin/w3m-0.5.2-1.README

mkdir -p usr/share/doc/w3m-0.5.2/ 

copy w3m-0.5.2/ABOUT-NLS ChangeLog NEWS README TODO usr/share/doc/w3m-0.5.2/

cd ~/ciw3m; tar cvfj w3m-0.5.2-1.tar.bz2  #<--binary is done can rm old build dir


Do source:
---------
mkdir ~/src/tmp; cd ~/src/tmp

Pure
$ tar xfz /home/bheckel/src/cygwin_w3m/gbs/newpkg/w3m-0.5.2.tar.gz

mv w3m-0.5.2/ w3m-0.5.2-1/

Pure
$ tar xfz /home/bheckel/src/cygwin_w3m/gbs/newpkg/w3m-0.5.2.tar.gz

cd w3m-0.5.2-1, mkdir CYGWIN-PATCHES/ cp setup.hint and README.w3m from CYGWIN-PATCHES.hold

diff -Nrup w3m-0.5.2/  w3m-0.5.2-1-src/ >w3m-0.5.2-1.patch

tar cfj w3m-0.5.2-1-src.tar.bz2 w3m-0.5.2-1.patch w3m-0.5.2-1-src

ok to rm both dirs


---


2010-10-04
IGNORED - WENT WITH CYGPORT DUE TO GC DOC LOCATION WEIRDNESS!!!!!see gmail
v7.1 gclib packaging - no changes to pristine source

Untar gc-7.1.tar.gz
edit libgc-7.1-1.sh for export BASEPKG=gc-7.1
mkdir libgc-7.1/CYGWIN-PATCHES 
add setup.hint and libgc.README
copy .sh from prev version, rename ...7.1-1...
edit .sh for "--docdir=/usr/share/doc/libgc-7.1" in conf()
./libgc-7.1-1.sh mkdirs  <--create empty dot dirs
./libgc-7.1-1.sh spkg  <--create cygwin src.tar.bz2 for the next step

cd /tmp
tar xvfj /home/bheckel/src/pkgd/libgc-7.1-1-src.tar.bz2
./libgc-7.1-1.sh prep
./libgc-7.1-1.sh conf
./libgc-7.1-1.sh build
./libgc-7.1-1.sh check
./libgc-7.1-1.sh install
make sure docs are in right places in .inst/
###./libgc-7.1-1.sh strip
./libgc-7.1-1.sh pkg  <--build /tmp/libgc-7.1-1.tar.bz2 (at least)
./libgc-7.1-1.sh spkg  <--build /tmp/libgc-7.1-1-src.tar.bz2 (at least)
./libgc-7.1-1.sh finish
/tmp/*bz2 are the important ones, delete the rest (including ~/src/...)
Upload ready or test it via
cd /; tar xvfj /tmp/libgc-7.1-1.tar.bz2

then recompile w3m
---




++++++++++++++++++++++++++++++++
To use w3m-0.5.1-1-src.tar.bz2 as an end user would:
$ cd /usr/src
$ tar xvfz  ~/install/w3m-0.5.1-1-src.tar.bz2
$ ./w3m-0.5.1-1.sh prep  <---patching file w3m-0.5.2/CYGWIN-PATCHES/setup.hint,w3m.README
                             and create temp dot dirs
$ ./w3m-0.5.1-1.sh conf
$ ./w3m-0.5.1-1.sh make
$ ./w3m-0.5.1-1.sh install
$ ./w3m-0.5.1-1.sh strip
$ ./w3m-0.5.1-1.sh pkg
$ cd /
$ tar xfj /usr/src/w3m-0.5.1-1.tar.bz2
$ cygcheck w3m
++++++++++++++++++++++++++++++++


---

2007-06-09 Upstream release 0.5.2-1 -

copy .sh from prev version as template 
tar xfz w3m-0.5.2.tar.gz
mkdir -p ~/projects/w3m-cygpkgV2/CYGWIN-PATCHES
vi CYGWIN-PATCHES/w3m.README  <---using prev version as template
vi CYGWIN-PATCHES/setup.hint  <---using prev version probably as is
./w3m-0.5.2-1.sh prep         <---create temp dot dirs
./w3m-0.5.2-1.sh conf
./w3m-0.5.2-1.sh make
./w3m-0.5.2-1.sh install  <---"install" to work dirs, not real install
###./w3m-0.5.2-1.sh strip  <---2007-06-09 gc throws:
GC Warning: Repeated allocation of very large block (appr. size 118784): May lead to memory leak and poor performance.
./w3m-0.5.2-1.sh pkg      <---w3m-0.5.2-1-src.tar.bz2 exists after running
###./w3m-0.5.2-1.sh spkg     <---w3m-0.5.2-1.tar.bz2 exists (final run only) after running
###./w3m-0.5.2-1.sh finish   <---wipe src dir? (final run only)

debugging shortcuts
./w3m-0.5.2-1.sh prep && ./w3m-0.5.2-1.sh conf && ./w3m-0.5.2-1.sh make && ./w3m-0.5.2-1.sh install && ./w3m-0.5.2-1.sh strip && ./w3m-0.5.2-1.sh pkg   
nostrip
###./w3m-0.5.2-1.sh prep && ./w3m-0.5.2-1.sh conf && ./w3m-0.5.2-1.sh make && ./w3m-0.5.2-1.sh install && ./w3m-0.5.2-1.sh pkg && ./w3m-0.5.2-1.sh spkg

cyginstall w3m-0.5.2-1.tar.bz2  <---to test


---

2007-03-31 Release 2 -

dload w3m-0.5.1-1-src.tar.bz2 from a mirror to extract upstream tar.gz
and .sh to
~/src/w3mdev (ok to delete the patch file), then tar xvfz w3m-0.5.1.tar.gz:

0 rsh86800@zebwl06a16349 w3mdev/ Fri Mar 30 13:20:51
$ ls
w3m-0.5.1/  w3m-0.5.1-1.sh*  w3m-0.5.1.tar.gz        <---all 3 must be there!

edit w3m-0.5.1/configure.in and other hacks required for cygwin
mkdir w3m-0.5.1/CYGWIN-PATCHES
create/edit CYGWIN-PATCHES/w3m.README  <---scp to sdf
create/edit CYGWIN-PATCHES/setup.hint  <---scp to sdf
rename (& mod if needed) w3m-0.5.1-1.sh (or generic-build-script.sh)
to w3m-0.5.1-2.sh
run ~/src/w3mdev/w3m-0.5.1-2.sh mkdirs
run ~/src/w3mdev/w3m-0.5.1-2.sh spkg
~/src/w3mdev/w3m-0.5.1-2-src.tar.bz2 now exists:

0 rsh86800@zebwl06a16349 w3mdev/ Fri Mar 30 13:26:14
$ ls
w3m-0.5.1/  w3m-0.5.1-2-src.tar.bz2  w3m-0.5.1-2.sh*  w3m-0.5.1.tar.gz

cd /tmp
tar xvfj ~/src/w3mdev/w3m-0.5.1-2-src.tar.bz2:

0 rsh86800@zebwl06a16349 tmp/ Fri Mar 30 13:28:10
$ ls
w3m-0.5.1-2.patch  w3m-0.5.1-2.sh*  w3m-0.5.1.tar.gz

./w3m-0.5.1-2.sh prep
./w3m-0.5.1-2.sh conf
./w3m-0.5.1-2.sh make
./w3m-0.5.1-2.sh install
./w3m-0.5.1-2.sh strip
./w3m-0.5.1-2.sh pkg
./w3m-0.5.1-2.sh spkg
./w3m-0.5.1-2.sh finish

or all

/tmp/w3m-0.5.1-2.tar.bz2 and /tmp/w3m-0.5.1-2-src.tar.bz2 now exist:

0 rsh86800@zebwl06a16349 tmp/ Fri Mar 30 13:50:04
$ ls
w3m-0.5.1-2-src.tar.bz2  w3m-0.5.1-2.sh*      w3m-0.5.1.tar.gz
w3m-0.5.1-2.patch        w3m-0.5.1-2.tar.bz2

scp w3m-0.5.1-2-src.tar.bz2 & w3m-0.5.1-2.tar.bz2 to sdf, delete the rest
(including the ~/src/w3m actually since the new changes are in -src.tar.bz):
$ scp w3m-0.5.1-2-src.tar.bz2 bheckel@sverige.freeshell.org:~/html/cygwin/w3m/

---



Orig upstream tarball, <pkg>.sh and my hacked source s/b untarred in this dir
with a CYGWIN-PATCHES dir holding the readme and setup.hint.  The src bz2 is
essentially a temp file that can be rm

Do not use <pkg>.sh 'first' parm, deletes source tree somehow


gc
==
Had to rename gc6.4.tar.gz libgc-6.4.tar.gz, unpacked it, renamed the dir,
re-tarred it, untarred it, added CYGWIN-PATCHES/libgc.README and
CYGWIN-PATCHES/setup.hint

/tmp must be empty of any gc or w3m working files prior to starting!

w3m
===
Must install gc libs to /usr ... first
Edit w3m-0.5.1-1.sh 
Create setup.hint and w3m.README in my source w3m-0.5.1/CYGWIN-PATCHES/
Edit configure.in for perl path

Speed test: 
time w3m -dump ~/code/misccode/bashref2_05.html >/dev/null
