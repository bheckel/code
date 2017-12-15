
libname myxml XML '.\_ADO_ASAMP.xml' xmlmap=asamp_0003e.map;
proc contents data=myxml._ALL_; run;
proc print data=myxml.TABLE(obs=500) width=minimum; run;
