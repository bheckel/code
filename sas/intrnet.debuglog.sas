 /* http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=LINKS.t.sas&UID=rsh86800&_debug=131 */

data foo;
  file 'd:/SAS_programs/bobtest.log';
  set sashelp.shoes;
  if product =: 'Boo';
  put _all_;
  file log;
  put product=;
run;

ods html body=_WEBOUT (dynamic title='browser titlebar') style=brick rs=none;
proc print data=_LAST_(obs=max); run;
ods html close;

