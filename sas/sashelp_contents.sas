options ls=max ps=max;

 /* Simple */
proc contents data=SASHELP._ALL_; run;

/*
  #  Name      Memtype   Level  File Size  Last Modified
--------------------------------------------------------------
  1  AC        CATALOG     2        17408   30JAN2001:11:00:00
  2  ADOMSG    DATA       17       148480   30JAN2001:11:00:00
     ADOMSG    INDEX                37888   30JAN2001:11:00:00
  3  ADSMSG    DATA        2       148480   30JAN2001:11:00:00
     ADSMSG    INDEX                37888   30JAN2001:11:00:00
  4  AFCLASS   CATALOG     2      1979392   30APR2002:05:28:46
  5  AFMSG     DATA        2       328704   30JAN2001:11:00:00
  ...
195  SHOES     DATA        2        41984   30JAN2001:11:00:00
196  SLIST     CATALOG     2        29696   30JAN2001:11:00:00
197  SQC       CATALOG    16      1709056   30JAN2001:11:00:00
198  SQL       CATALOG     2      1164288   30JAN2001:11:00:00
*/



 /* Detailed */
proc datasets library=sashelp nolist;
  contents data=_all_ out=work.sashelp_ds_metadata (keep=libname memname name type length label format nobs compress sorted idxusage crdate modate)
  noprint directory;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

