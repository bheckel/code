options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: read_ds_create_sasformat.sas
  *
  *  Summary: Build a temporary format using a dataset.
  *
  *           See also cntlin.sas
  *
  *  Created: Thu 13 May 2010 10:06:46 (Bob Heckel)
  * Modified: Wed 13 Jul 2016 10:04:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc contents data=SASHELP.shoes out=t(keep= name type) NOprint; run;

data t(drop=type);
  set t;
  chartype = put(type, F8.);
run;
proc contents; run;

data ctrl(rename=(name=START chartype=LABEL));
   set t end=e;
   /*  Mandatory to name the format here */
   retain fmtname '$f_pts';
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /*
Obs    START         LABEL    fmtname

 1     Inventory       1      $f_pts 
 2     Product         2      $f_pts 
 3     Region          2      $f_pts 
 4     Returns         1      $f_pts 
 5     Sales           1      $f_pts 
 6     Stores          1      $f_pts 
 7     Subsidiary      2      $f_pts 
 */


 /* Use the dataset to build the temporary format */
proc format library=work cntlin=ctrl; run;

 /* Print format for debugging */
proc format library=work FMTLIB;
 /*
----------------------------------------------------------------------------
|       FORMAT NAME: $F_PTS   LENGTH:    8   NUMBER OF VALUES:    7        |
|   MIN LENGTH:   1  MAX LENGTH:  40  DEFAULT LENGTH:   8  FUZZ:        0  |
|--------------------------------------------------------------------------|
|START           |END             |LABEL  (VER. V7|V8   13JUL2016:10:00:22)|
|----------------+----------------+----------------------------------------|
|Inventory       |Inventory       |1                                       |
|Product         |Product         |2                                       |
|Region          |Region          |2                                       |
|Returns         |Returns         |1                                       |
|Sales           |Sales           |1                                       |
|Stores          |Stores          |1                                       |
|Subsidiary      |Subsidiary      |2                                       |
----------------------------------------------------------------------------
 */

 /* 2 */
%put !!! %sysfunc(putc(Product, $f_pts.));
