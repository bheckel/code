20-Mar-13

Setup libname:
D:\SAS Files\V8\IntrNet\default\appstart.sas


14-May-12

See sas_intrnet.html or below for a good overall demo (the .asp examples are too confused):

t.html (in an IIS-aware place):
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- Save this file to a webserver ready dir -->
<!-- Make sure .sas file is in an Intrnet-aware dir: LINKS (d:\sas_programs), nchscode, etc -->

<!-- Call via: http://localhost/intrnet/sas_intrnet_test.html -->
<!--           http://rtpsawn321/links/t.html -->

<!-- or bypass this page and just run the SAS code -->
<!-- http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=LINKS.t.sas&UID=foo&_debug=131 -->

<!-- Modified: Thu 29 Apr 2010 13:57:45 (Bob Heckel) -->

<HTML>
<HEAD>
  <TITLE>Testing SAS IntrNet</TITLE>
</HEAD>
<BODY>
  <FORM ACTION="http://rtpsawn321/sasweb/cgi-bin/broker.exe" METHOD="POST" NAME="the_form">
    <INPUT TYPE="hidden" NAME="_DEBUG" VALUE="131">
    <INPUT TYPE="hidden" NAME="_SERVICE" VALUE="default">
    <INPUT TYPE="hidden" NAME="_PROGRAM" VALUE="DPDEMO.t.sas">
    <INPUT TYPE="hidden" NAME="the_type" VALUE="42">
    <INPUT NAME="the_textbox" TYPE="text" VALUE="none provided">
    <INPUT NAME="the_submit" TYPE="submit">
  </FORM>
</BODY>
</HTML>


t.sas (in a SAS libname-aware place):
options nosource;
 /*---------------------------------------------------------------------
  *     Name: sas_intrnet.sas
  *
  *  Summary: Demo pgm for SAS IntrNet.  Call via:
  *           http://localhost/cgi-sas/broker?_service=default&_program=intrcode.sas_intrnet.sas&the_type=42&the_textbox=43&_DEBUG=131
  *
  *           or use sas_intrnet_test.html
  *
  *  Created: Sat 19 Oct 2002 12:18:18 (Bob Heckel)
  *---------------------------------------------------------------------
  */
data work.sample1;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  datalines;
one           two            123
three         four           123
five          six            123
seven         eight          345
  ;
run;

ods html body=_WEBOUT (dynamic title='HTML titlebar') style=brick rs=none;
  title "ok the_type (hidden): &the_type the_textbox: &the_textbox";
  proc print; run;
ods html close;


Run in IE:
http://rtpsawn321/datapostDEMO/t.html


-----


2011-07-15 Remove the footer message:

"This request took 0.30 seconds of real time (v9.1 build 1461)."

Stop SAS Load Mgr Service
Uncomment and set Debug 0 in d:\inetpub\wwwroot\sasweb\cgi-bin\broker.cfg
Start SAS Load Mgr Service

Now must use
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=DPDEMO.t.sas&_DEBUG=3
to get timing to display in browser footer

----

2011-05-18 Allocate IntrNet library:

http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=ping&_adminpw=
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_DEBUG=16384&_SERVICE=default
if ok then:
Stop SAS Load Mgr Service
vi D:\SAS Files\V8\IntrNet\default\appstart.sas to add/edit these 2 lines:
  allocate file DP 'e:\datapost\code';  <---usually add
  proglibs sample demo links DP utc samplib %ifcexist(sashelp.webeis) sashelp.webprog;  <--usually edit
Start SAS Load Mgr Service
put helloworld.intrnet.sas in e:\...
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=dp.t.sas

----

2010-05-04

See readme.apache2.txt for installing on Cygwin


-----

Note: no numbers allowed in filename e.g. this won't work!:
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=LINKS.bobh1menu.sas&UID=rsh86800&Submit=Control+Table+Menu&_debug=131


-----


2006-08-01 test run d:\sas_programs\t.sas on blade: 

http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=LINKS.t.sas&UID=rsh86800&_debug=131

-----

http://support.sas.com/rnd/web/intrnet/



Installation:
============
2002-10-18 (same on 9.1 unless noted)
On parsifal:

* Set up Apache webserver ::::::::::::::::::::::

For static docs--
$ mkdir ~/public_html/sasweb
Make a dummy index.html and cp to ~/public_html/sasweb/
$ vi /etc/apache/conf/httpd.conf
  Add:
  Alias /intrnet/ "/home/bheckel/public_html/sasweb/"

$ /usr/sbin/apachectl restart
  Test index.html via: http://localhost/intrnet/

For CGI apps--
$ mkdir ~/public_html/cgi-sas
$ cp ~/code/misccode/test-cgi ~/public_html/cgi-sas/
$ vi /usr/local/apache/conf/httpd.conf
  Add:
  ScriptAlias /cgi-sas/  /home/bheckel/public_html/cgi-sas/

$ /usr/sbin/apachectl restart
  Test via: http://localhost/cgi-sas/test-cgi?foo=barz
  May need to add <Directory...> directives for intrnet/ and cgi-sas/

Make sure Moz is set with Keep Alive property unchecked.

* Set up Application Server ::::::::::::::::::::::

Run the IntrNet Wizard (a.k.a.
"C:\Program Files\SAS Institute\SAS\V8\intrnet\sasexe\inetcfg.exe")
from Start:Programs:SAS...
Choose socket, the default selected radio button
OK to not use as a Service (so say No but probably won't be asked).  Use port
5001.
Name the Service 'default' <---that sets the directory name to 'default'


* Set up SAS CGI Web Tools on the webserver machine :::::::::::::::::::::::
Run the websrv.exe installer (a.k.a. Windows version SAS/IntrNet CGI Tools
that you dloaded from support.sas.com/rnd/web).
Fill textbox with:
c:\cygwin\home\bheckel\public_html\sasweb
Fill textbox with:
c:\cygwin\home\bheckel\public_html\cgi-sas
Fill textbox with:
http://localhost/cgi-sas/
With either Apache or IIS running, test via:
http://localhost/cgi-sas/broker.exe?  or  http://localhost/scripts/broker.exe?
$ vi /home/bheckel/public_html/cgi-sas/broker.cfg
   Edit email contact addresses.
   ###Server appsrv.yourcomp.com
   Server localhost

Make sure an OS-appropriate version of broker.exe exists in
~/public_html/cgi-sas/ and then create new
vi ~/public_html/cgi-sas/broker.cfg:

  SocketService default
    ServiceAdmin "Bob"
    ServiceAdminMail "bheckel@gmail.com"
    Server       RTP-BQH0-159090.nchs.cdc.gov   <--IntrNet appserver's hostname
    Port         5001
    FullDuplex  True


* Set up local Windows Network :::::::::::::::::::::::
Edit /c/WINNT/system32/drivers/etc/services adding this line:
default          5001/tcp                           # 2002-10-16 SAS IntrNet


* Set up IntrNet server ::::::::::::::::::::::: 
Edit:
/C/Documents and Settings/Bob Heckel/My Documents/My SAS Files/V8/IntrNet/default/appstart.sas
Add this:
 allocate library intrdata 'C:\cygwin\home\bheckel\public_html\sasweb';    
 allocate file intrcode 'C:\cygwin\home\bheckel\public_html\cgi-sas';
 proglibs intrcode;
 datalibs intrdata;

ONE TIME SETUP IS COMPLETE AT THIS POINT



Run PC as Server:
================
* Start webserver:
$ apachectl start    (/usr/sbin/apachectl start on CDC)

* Start SAS Intrnet:
Start:Programs:The SAS System:IntrNet:default service:Start Interactively
(this is the same as running "C:\Documents and Settings\nchsuser\My
Documents\My SAS Files\V8\IntrNet\default\appstart.bat")

2005-03-31 Assuming this is in httpd.conf:

    ScriptAlias /cgi-sas/ "/home/bqh0/public_html/cgi-sas/"
    <Directory "/home/bqh0/public_html/cgi-sas">
        AllowOverride None
        Options None
        Order allow,deny
        Allow from all
    </Directory>

You can test the SAS Server without a program via:
"Administrative program"
http://localhost/cgi-sas/broker.exe?_SERVICE=default&_PROGRAM=status
http://localhost/scripts/broker.exe?_SERVICE=default&_PROGRAM=ping
http://us7n98/scripts/broker.exe?_DEBUG=16384&_SERVICE=default
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=ping&_adminpw=
http://us8n37/scripts/broker.exe?_service=default&_program=ping&_adminpw=

Have debug info returned like my cgi_template.pl's "ENVIRONMENT"
http://mainframe.cdc.gov/sasweb/cgi-bin/broker?_DEBUG=16384&_SERVICE=default
http://rtpsawn321/sasweb/cgi-bin/broker.exe?_DEBUG=16384&_SERVICE=default
Out of the box:
http://zebwl10d43164/cgi-bin/broker?_DEBUG=16384&_SERVICE=default

D:\Inetpub\wwwroot\sasweb\cgi-bin\broker.cfg


2005-03-31 Assuming this is on before the run statement
in C:/Documents and Settings/Owner/My Documents/My SAS Files/V8/IntrNet/default/appstart.sas (no longer in appstart.bat!!):
or
s:/sas_files/v8/intrnet/default/appstart.sas

paths refer to the IntrNet server box, the webserver only holds broker.exe!

    allocate library intrdata 'C:\cygwin\home\bheckel\intrnet;    
    allocate file intrcode 'C:\cygwin\home\bheckel\intrnet;
    proglibs intrcode;
    datalibs intrdata;

If your service is named 'default' on IIS use this:
http://us7n98/sasweb/IntrNet8/samples.html
else
You can create a helloworld.sas like this one in the intrcode dir (e.g.
/home/bheckel/public_html/cgi-sas/)
data _NULL_;
  put 'Hello World';
  put "&foo";
run;

Filenames must be foo.sas (not foo.bar.sas).  Case insensitive.

Canonical test helloworld via (&foo is passed to runrpts.sas from the URL):
http://localhost/cgi-sas/broker?_SERVICE=default&_PROGRAM=intrcode.helloworld.sas&type=42&_DEBUG=131

  Can use FILE _WEBOUT; to put to the browser in a data _NULL_; or

  ods html body=_WEBOUT (dynamic title='Your Results') style=brick rs=none;
    proc print; run;
  ods html close;
  to print a proc to the browser.

  See ~/code/sas/sas_intrnet_test.html for the way to design a form.


-----

Debug codes:

1     Echoes all fields. This is useful for debugging value-splitting problems.

2     Prints Broker version number and elapsed time after each run, for 
      example, "This request took 2.46 seconds of real time (v8.0 build
      1316)." Also, this value displays the Powered by SAS logo if you provide
      additional settings as described in Displaying the Powered by SAS Logo.

4     Lists definitions of all services as defined by the administrator, but

      does not run the program.
8     Skips all execution processing.

16    Displays output in hexadecimal. This is extremely helpful for debugging
      problems with the HTTP header or graphics.

32    Displays the Powered by SAS logo without Broker version or elapsed time
      information. See also Displaying the SAS Powered Logo.

128   Returns log file. This is useful for diagnosing problems in the SAS
      code.

256   Traces socket connection attempts. This is helpful for diagnosing the
      machine selection process.

512   Shows socket host and port number in status message (by default off for
      security reasons).

1024  Echoes data usually sent from Broker to the Application Server. It does
      not run the program. In the case of a launch service, this also shows the SAS
      command that would have been invoked by the Broker.

2048  Provides more extensive socket diagnostics.

4096  Prevents the deletion of temporary files that are created for launch.
      This is useful for debugging configuration problems in a launch service
      (prior to Version 8).

8192  Returns entire SAS log file from a launched service (prior to Version 8).

16384 Displays the Broker environment parameters.

32703 (bobh) 'ping' or stop server via a link

