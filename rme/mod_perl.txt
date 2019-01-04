Installation
============

See ~/code/misccode/mod_perl_install.pdf

Must be bheckel for some reason.
$ su bheckel
Untar apache and mod_perl tarballs in ~bheckel/src/

$ cd ~/src/mod_perl-1.26

$ perl Makefile.PL \                                             
> APACHE_SRC=../apache_1.3.22/src \
> APACHE_PREFIX=/usr/local/apache \
> EVERYTHING=1 \
> DO_HTTPD=1 \
> USE_APACI=1 \
> APACI_ARGS='--enable-module=rewrite, \
>             --enable-module=info, \
>             --enable-module=expires, \
>             --enable-module=userdir'

or pasteable
perl Makefile.PL APACHE_SRC=../apache_1.3.22/src APACHE_PREFIX=/usr/local/apache EVERYTHING=1 DO_HTTPD=1 USE_APACI=1 APACI_ARGS='--enable-module=rewrite, --enable-module=info, --enable-module=expires, --enable-module=userdir'

$ make
$ make test
$ su
$ make install
$ vi  /usr/local/apache/conf/httpd.conf
Change nobody's group from "-1" to nobody
$ /usr/local/apache/bin/apachectl start
$ exit

Default httpd.conf uses port 8080.  Test in browser (Opera is best) via:
http://172.16.187.129:8080/
