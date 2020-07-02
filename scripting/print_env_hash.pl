#!/usr/local/bin/perl 

print "Content-type: text/html\n\n"; 
print "<tt>\n"; 
foreach $key (sort keys(%ENV)) { 
   print "$key = $ENV{$key}<p>"; 
}

#Will output to browser:
#
#DOCUMENT_ROOT = /home/rtpwww/docs
#
#GATEWAY_INTERFACE = CGI/1.1
#
#HTTP_ACCEPT = image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
#
#HTTP_ACCEPT_CHARSET = iso-8859-1,*,utf-8
#
#HTTP_ACCEPT_ENCODING = gzip
#
#HTTP_ACCEPT_LANGUAGE = en
#
#HTTP_CONNECTION = Keep-Alive
#
#HTTP_COOKIE = pref_multiselect=CHECKED
#
#HTTP_HOST = 47.192.6.254
#
#HTTP_USER_AGENT = Mozilla/4.06 [en] (Win95; I)
