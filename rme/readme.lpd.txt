Test:
$ cat foo.txt > /dev/lp0

for the HP printer Laserjet IIIsi
  1.  go offline
  2.  formfeed
  3.  go online


Install lprng-3.8.12.tar.gz
$ ./configure

$ mkdir /var/spool/lpd  <---chmod 755 owner root group root
$ mkdir /var/spool/lp   <---chmod 700 owner daemon group daemon
$ vi /usr/local/etc/termcap
$ checkpc -V
Restart lpd (debug is lpd -F -D1)
Do symlinks as requested by INSTALL


Install ifhp-3.5.8
Add :ifhp=model=hp3si:\
    :filter=/usr/local/libexecl/filters/ifhp:
Restart lpd (debug is lpd -F -D1)
