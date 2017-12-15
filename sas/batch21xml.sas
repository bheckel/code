options ls=180;

libname inxml XML 'C:\cygwin\home\bheckel\projects\datapost\tmp\batch21\xml\atbe.xml' xmlmap=t4.map access=READONLY;

title 'batch';
data areabatch(rename=(name=areanm));
  merge inxml.area inxml.batch;
  by area_ordinal;
run;
data batchcharist;
  merge areabatch inxml.characteristic;
  by batch_ordinal;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/
data charistvalue;
  merge batchcharist inxml.value;
  by characteristic_ordinal;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/
/***proc sql;CREATE INDEX charistvalue ON charistvalue (handle,batch_ordinal,instance,isUTC);quit;***/
proc transpose data=charistvalue out=flipcharistvalue(drop=_:);
  by handle batch_ordinal;
  id name;
  var value;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'batch & subbatch';
data valuesubb;
  merge flipcharistvalue inxml.subbatch(rename=(name=subbnm));
  by batch_ordinal;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
data charist1val1;
  merge valuesubb inxml.characteristic1;
  by subbatch_ordinal;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/
data l.final;
  merge charist1val1 inxml.value1;
  by characteristic1_ordinal;
run;
proc print data=_last_ width=minimum; run;
