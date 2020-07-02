#!/usr/bin/perl -w

# Run from browser, displays content similar to this:
#
# DOCUMENT_ROOT = /home/rtpwww/docs
# GATEWAY_INTERFACE = CGI/1.1
# HTTP_ACCEPT = image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
# HTTP_ACCEPT_CHARSET = iso-8859-1,*,utf-8
# HTTP_ACCEPT_ENCODING = gzip
# HTTP_ACCEPT_LANGUAGE = en
# HTTP_CONNECTION = Keep-Alive
# HTTP_HOST = triweb
# HTTP_USER_AGENT = Mozilla/4.51 [en] (Win95; U)
# PATH = /usr/bin:/usr/sbin:/sbin
# PATH_INFO = 
# PATH_TRANSLATED = /home/rtpwww/docs
# QUERY_STRING = 
# REMOTE_ADDR = 47.143.17.107
# REMOTE_PORT = 3324
# REQUEST_METHOD = GET
# REQUEST_URI = /csf1-cgi/test/environ_html.pl
# SCRIPT_FILENAME = /home/rtpwww/www/cgi-bin/cgiwrap
# SCRIPT_NAME = /cgi-bin/cgiwrap/csf1/test/environ_html.pl
# SCRIPT_URI = http://47.192.6.254/csf1-cgi/test/environ_html.pl
# SCRIPT_URL = /csf1-cgi/test/environ_html.pl
# SERVER_ADMIN = baptiste@nortel.com
# SERVER_NAME = 47.192.6.254
# SERVER_PORT = 80
# SERVER_PROTOCOL = HTTP/1.0
# SERVER_SOFTWARE = Apache/1.3.1 (Unix)
# TZ = EST5EDT

###require "/triweb/tools/cgilibs/cgi-lib.pl";
print "Content-type:text/html\n\n";
###&PrintHeader("myhead");
print"<tt>\n";
foreach $key(sort keys(%ENV)) {
  print "$key = $ENV{$key}<p>";
}

###&HtmlBot;


