options nosource;
 /* 
  * See readme.sasintrnet.txt
  *
  * Call via:
  * http://localhost/cgi-sas/broker?_SERVICE=default&_PROGRAM=intrcode.helloworld.intrnet.sas&type=42&_DEBUG=131 
  * or
  * http://mainframe.cdc.gov/sasweb/cgi-bin/broker?_DEBUG=131&_SERVICE=default&_PROGRAM=nchscode.hello.sas
  *
  * Must reside in a directory that IntrNet knows about and has established a
  * libname for (e.g. intrcode).
  *
  * Also see more complicated examples in sas_intrnet.html and
  * sas_intrnet.sas
  *
  */
data work.tmp;
  infile cards;
  input id $  pw $;
  cards;
bqh0 x
abc1 y
  ;
run;


 /* Ugly */
data _null_;
  set tmp;
  file _webout;
  put _all_;
run;


 /* Slightly less ugly */
ods html body=_WEBOUT (dynamic title='browser titlebar') style=brick rs=none;
proc print; run;
ods html close;

%put _ALL_;
