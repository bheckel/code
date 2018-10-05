24-Apr-13

add to cygport:
libgc_CONTENTS='usr/share/doc/Cygwin/libgc.README'

cygport libgc-7.2d-1 prep
vi ./libgc-7.2d-1/src/gc-7.2/CYGWIN-PATCHES/README
...compile install package
Edit main setup.hint "requires: libgc1"

cd dist/libgc, tar it, scp to sdf cygwin/libgc64

---

22-Apr-13

64bit initial pkg
Using Corinna's mlist suggestions, patch pristine.
Add PATCH_URI="patch64.diff" to .cygport
cygport libgc-7.2d-1.cygport prep 
cygport libgc-7.2d-1.cygport compile
cygport libgc-7.2d-1.cygport install
cygport libgc-7.2d-1.cygport package

Manually added "requires: libgc1" to libgc-7.2d-1/dist/libcg/setup.hint

23-Apr-13

-2 add a nearly empty bz2 as toplevel README holder (like libgcj)
usr/share/doc/Cygwin/libgc.README
---

02-Sep-12

Used .cygport from Yaakov.  It left out the toplevel .bz2 so I built it by hand
using the source gc...gz docs then added a Cygwin/libgc.README.  Then wrote
each setup.hint on sdf as needed.  Ignored the atomic bz2.

---

25-May-12

download http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/ and untar as is


$ ./configure --prefix=/home/rsh86800/gc-7.2b/.inst/usr --libexecdir=/home/rsh86800/gc-7.2b/.inst/usr/lib --sysconfdir=/home/rsh86800/gc-7.2b/.inst/etc --localstatedir=/home/rsh86800/gc-7.2b/.inst/var --datadir=/home/rsh86800/gc-7.2b/.inst/usr/share --mandir=/home/rsh86800/gc-7.2b/.inst/usr/share/man --infodir=/home/rsh86800/gc-7.2b/.inst/usr/share/info

$ make

$ make check

$ make install

usr/lib/pkgconfig/bdw-gc.pc needs edit to erase .inst faking
sample from previous version:
prefix=/usr
exec_prefix=/usr
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Boehm-Demers-Weiser Conservative Garbage Collector
Description: A garbage collector for C and C++
Version: 7.1
Libs: -L${libdir} -lgc
Cflags: -I${includedir}

Add this to .inst/usr/share/doc/Cygwin/libgc.README
    libgc
    ------------------------------------------
    The Boehm-Demers-Weiser conservative garbage collector can be used as a
    garbage collecting replacement for C malloc or C++ new. It allows you to
    allocate memory basically as you normally would, without explicitly
    deallocating memory that is no longer useful. The collector
    automatically recycles memory when it determines that it can no longer
    be otherwise accessed.

    The collector is also used by a number of programming language
    implementations that either use C as intermediate code, want to
    facilitate easier interoperation with C libraries, or just prefer the
    simple collector interface.

    Alternatively, the garbage collector may be used as a leak detector for
    C or C++ programs, though that is not its primary goal. 

    Runtime requirements (these or newer):
      cygwin-1.7.1-1
      libgcc1-4.3.4-3

    Canonical website:
      http://www.hpl.hp.com/personal/Hans_Boehm/gc/

    Canonical download:
      http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/

    -------------------------------------------

    Build instructions:
      unpack libgc-7.2-X-src.tar.bz2
        if you use setup to install this src package, it will be
       unpacked under /usr/src automatically

    This will create:
      /usr/src/libgc-7.1-X-src.tar.bz2
      /usr/src/libgc-devel-7.1-X.tar.bz2
      /usr/src/libgc1-7.1-X.tar.bz2

    To find out the files included in the binary distribution, you can use
    cygcheck, or browse the listing for the appropriate version at
    <http://cygwin.com/packages/>.
    -------------------------------------------

    Port Notes:

    ----------  libgc7.2b-1 2012-05-24 -----------
    * New upstream release.

    ----------  libgc7.1-1 2010-10-10 -----------
    * New upstream release.
    * Shared library now available.
    * Packaged using cygport (thanks to Yaakov Selkowitz 
      http://sourceware.org/cygwinports/)

    ----------  libgc6.4-1 2005-04-15 -----------
    * Initial release.
      Thanks to Jason Tishler for his very valuable assistance in testing and
      debugging performance issues.

    Originally ported for use by the w3m package.

    ------------------------------------------

    For more information about this package, see the upstream documentation in
    /usr/share/doc/<PKG>-<VER>.

    Cygwin port maintained by: Robert S. Heckel Jr. <b.heckel AT gmail>
    Please address all questions to the Cygwin mailing list


TODO binary tarball
TODO source tarball wo readme
TODO source tarball with readme, then patch


---

See fairly useless gmail "libgc build note" for cygport 7.1 build

---

Obsolete 2010-09-28 
to get v7 to compile:
$ ./configure --enable-threads=posix --disable-shared


2005-??-??
tar xfz gc6.8.tar.gz 
mv gc6.8/ libgc-6.8/
mv gc6.8.tar.gz libgc-6.8.tar.gz

strip??
./libgc-6.8-1.sh prep && ./libgc-6.8-1.sh conf && ./libgc-6.8-1.sh make && ./libgc-6.8-1.sh install && ./libgc-6.8-1.sh pkg && ./libgc-6.8-1.sh spkg

