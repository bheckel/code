
 /* In SAS GUI Editor run:
  * libname myscl 'C:\cygwin\home\bheckel\tmp\03Mar09_1236096131';
  * In SAS GUI cmdline box run:
  * build myscl.catalog.HELLO.scl  <--opens mainframe-like editor on HELLO inside catalog.sas7bcat
  * In the resulting mainframe-like Build Window type then compile then save/close:
  */
init:
/* Get the value of the macro variable passed in */
message1=symget('message1');
/* Put a message to the Log */
put "!!! Hello World " message1;
/* Return a value in a macro variable */
call symput('retinfo','The program was a success');
return;


 /* Run this to compile (or simply drilldown to select HELLO in GUI SAS Explorer, right click Compile).
  * Build Window must be closed for this work.
  */
libname myscl 'C:\cygwin\home\bheckel\tmp\03Mar09_1236096131';
proc build catalog=myscl.catalog.HELLO.scl batch;
  compile entrytype=scl;
run;


 /* Run this to test: */
libname myscl 'C:\cygwin\home\bheckel\tmp\03Mar09_1236096131';
%let message1=it ran;
proc display c=myscl.catalog.HELLO.scl;run;
%put _all_;




endsas;
 /* Now you can mess around with things like COM: */
init:

hostcl = loadclass('SASHELP.fsp.hauto');
declare NUM errnum;
declare CHAR (40) ver;
declare CHAR (150) p pcon pqry pxml;
declare CHAR (1000) errdesc;
declare OBJECT o oerr ;

p = symget('DLIPATH');
put 'DLI:' p=;
pcon = p || 'ADO_FW.con';
put 'DLI:' pcon=;
pqry = p || 'ADO_FW.qry';
put 'DLI:' pqry=;
pxml = p || 'ADO_FW.xml';
put 'DLI:' pxml=;

call send(hostcl, '_NEW_', o, 0, 'DataLink.Microsoft.ADO.Net.Adapter.Instance');

call send(o, '_SET_PROPERTY_', 'UseFileIO', 1);

call send(o, '_SET_PROPERTY_', 'ConnectionString', pcon);

call send(o, '_SET_PROPERTY_', 'SQLQuery', pqry);

call send(o, '_SET_PROPERTY_', 'XMLOutputFileOverwrite', 1);

call send(o, '_DO_', 'Execute', pxml);

call send(o, '_GET_PROPERTY_', 'Version', ver);

/* In VBA it this would simply be:  If Obj_B21WS.ErrorStatus.EventID = 0 Then ... */
call send(o, '_GET_PROPERTY_', 'ErrorInfo', oerr);
call send(oerr, '_GET_PROPERTY_', 'EventID', errnum);
call send(oerr, '_GET_PROPERTY_', 'Description', errdesc);

call send(o, '_TERM_');

put "DLI: XML saved to file ADO_FW.xml, errnum should be 0";
put 'DLI:' ver= errnum= errdesc=;

return;



OR IP21:

init:

hostcl = loadclass('SASHELP.fsp.hauto');
declare NUM errnum;
declare CHAR (40) ver;
declare CHAR (150) p pcon pqry pxml;
declare CHAR (1000) errdesc;
declare OBJECT o oerr ;

p = symget('DLIPATH');
put 'DLI:' p=;
pcon = p || 'WSIP21.con';
put 'DLI:' pcon=;
pqry = p || 'WSIP21.qry';
put 'DLI:' pqry=;
pxml = p || 'WSIP21.xml';
put 'DLI:' pxml=;

call send(hostcl, '_NEW_', o, 0, 'DataLink.AspenTech.SQLPlus.Adapter.Instance');

call send(o, '_SET_PROPERTY_', 'UseFileIO', 1);

call send(o, '_SET_PROPERTY_', 'WebServiceURL', pcon);

call send(o, '_SET_PROPERTY_', 'WebServiceQueryXML', pqry);

call send(o, '_SET_PROPERTY_', 'XMLOutputFileOverwrite', 1);

call send(o, '_DO_', 'Execute', 1, '', '', '', pxml);

call send(o, '_GET_PROPERTY_', 'Version', ver);

/* In VBA it this would simply be:  If Obj_B21WS.ErrorStatus.EventID = 0 Then ... */
call send(o, '_GET_PROPERTY_', 'ErrorInfo', oerr);
call send(oerr, '_GET_PROPERTY_', 'EventID', errnum);
call send(oerr, '_GET_PROPERTY_', 'Description', errdesc);

call send(o, '_TERM_');

put "DLI: XML saved to file WSIP21.xml, errnum should be 0";
put 'DLI:' ver= errnum= errdesc=;

return;
