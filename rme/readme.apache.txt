
2007-03-04 still true for v1.3 (NOT v2 which has contradictory instructions
about cygrunsrv and doesn't appear worth the effort)

2002-10-16 Cygwin installation (no make... required)
Start via:
$ /usr/sbin/apachectl start

Test in browser via:
  http://localhost
and
  http://localhost/cgi-bin/printenv

Add this:
  ScriptAlias /bqh0/cgi-bin/ "/home/bqh0/public_html/cgi-bin/"
to /etc/apache/httpd.conf
Restart server via (MAY NOT WORK, but does on parsifal, BETTER TO STOP 'N'
START): 
$ /usr/sbin/apachectl restart

Test in browser via:
  http://localhost/bqh0/cgi-bin/get_ncsa_qry.exe?foo=bar
or better
  http://localhost/bqh0/cgi-bin/cgi_template.pl

Kill via:
$ /usr/sbin/apachectl stop


----


2004-01-21 Misc from http://www.unixreview.com/documents/s=8989/ur0401g/
service httpd restart
or
/etc/rc.d/init.d/httpd restart
or
apachectl restart


On some versions of Apache, the default directory is /var/www/html. For
others, it's /usr/local/apache or /usr/local/apache2. With the DocumentRoot
directive, you can change the directory for Web pages as you wish. 

A somewhat-related directive is ServerRoot. It's used to set the directory for
configuration files and logs. By default, this is set to /usr/local/etc/httpd
with a sub-directory conf for configuration files, and another called logs for
log files. On some systems, you may find these sub-directories in /etc/httpd.
You may also find the Apache logs located in the /var/log/httpd directory. 


----

~/.htaccess contents:
AuthType Basic
AuthName "Bobh Page"
AuthUserFile /home/xinu/.htpasswd
require valid-user

Password:
/httpd/bin/htpasswd ~/.htpasswd xinu

-----

05/06/02
daeb Debian box
Assigned nobody password daebNobody but don't think I needed to.
Didn't have to move httpd
$ newgrp nogroup  <---for nobody
Somehow nobody was automatically assigned to nogroup.
As root:
$ /usr/local/apache/bin/apachectl start   <---switches ownership to nobody
Accessible via: http://daeb  or  http://daeb/~bqh0/
CGI test:
First:  daeb:/usr/local/apache/cgi-bin# chmod 755 printenv
Then http://daeb/cgi-bin/printenv
This works b/c of my hosts file mapping daeb to 158.111.250.128

ScriptAlias /cgi-bin/ "/usr/local/apache/cgi-bin/"
ScriptAlias /bqh0/cgi-bin/ "/home/bqh0/public_html/cgi-bin/"
Test  ~/bqh0/public_html/cgi-bin/cgi_template.pl  via:
http://158.111.250.128/bqh0/cgi-bin/cgi_template.pl


-----


Make sure .cad files are 'Open With...' instead of just producing the text
contents, add to httpd.conf:

  AddType application/igeviewer .cad


-----


To be able to check your Apache server's status via a web
browser, add the following to your
apache_home/etc/access.conf file: 
ExtendedStatus On 
<Location /server-status> 
SetHandler server-status 
order deny,allow 
deny from all 
allow from .domain.com 
</Location>
Make sure to change the domain to whatever domain you want
the status screen to be available to, here we used
domain.com. After restarting the server, you can look up
server stats at, in this example,
http://www.domain.com/server-status
or
http://daeb/server-status?refresh=10


-----


To allow browsing the filesystem via a browser:

# Viewable via http://47.143.210.230/Webcad/data/
Alias /Webcad/data /gr8xprog/
<Directory "/gr8xprog">
    Options Indexes MultiViews
    AllowOverride None
    Order allow,deny
    Allow from all
    <Files ~ "\.(obc|tpg|ckt|pod)$">
      # TODO except Mike Cook?
      Deny from all
    </Files>
</Directory


----

Secure a directory(s) with a single userid and pw:

- Create .htpasswd in some top level dir
  .htpasswd sample:
  custsvcguest: s2QJwZWCQnB9Q      <---encrypted via htpasswd(1) or crypt(1)

- mkdir the dir to be secured

- chmod 750 the directory

- chgrp rtpwww the directory  ??

- chmod 644 .htpasswd

- Place a copy of .htaccess in each dir to be secured
  .htaccess sample:
  AuthType Basic
  AuthName "Dept 7020 Finance"     <---shows in Message Box
  AuthUserFile /triweb/CustSvcFin/.htpasswd
  <Limit GET POST>
    require valid-user
  </Limit>

- chmod 644 .htaccess


----



07/30/01  (note: Doesn't apply to Cygwin that includes Apache, see below)
Cygwin compiles OOTB.  Or use the Cygwin setup.exe package.
./configure --prefix=/usr/local/apache
make
make install

Must move src/httpd.exe manually to /usr/local/apache/bin (for some reason).
$ mv src/httpd.exe /usr/local/apache/bin 
$ rm /usr/local/apache/conf/httpd.conf
$ ln -s ~/code/html/httpd.conf /usr/local/apache/conf/httpd.conf
$ apachectl start

May want to 
$ cd /; ln -s /usr/local/apache /apache


