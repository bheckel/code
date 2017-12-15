options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pdv.sas
  *
  *  Summary: View the datastep while reading raw data and SAS dataset.
  *
  *  Created: Fri 11 Jun 2010 10:59:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* NOTE _N_=4 is reached in both! */

data t;
  put 'Raw data read - initialized all set to missing';
  put _ALL_;

  input  id  x  y;
  z+1;  /* accumulator sum statement */
  zz = x+1;  /* NOT what you expect w/o RETAIN */

  put '!!! after';
  put _ALL_; put;
  cards;
1   88   99
2   66   97
3   44   55
  ;
run;



data t;
  put 'Existing SAS Dataset initialized all maintain values';
  put _ALL_;

  set sashelp.shoes(keep= region sales obs=3) end=e;
  z+1;
  zz = sales+1;  /* NOT what you expect w/o RETAIN */

  put '!!! after';
  put _ALL_; put;
run;
