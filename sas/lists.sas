options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lists.sas
  *
  *  Summary: Alternate ways of building lists
  *
  *  Adapted: Fri 29 Jul 2016 09:42:26 (Bob Heckel--http://support.sas.com/resources/papers/proceedings15/2220-2015.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc sql noprint;
  /* Create a horizontal list */
  select name into :nameSQL separated by ' ' 
  from sashelp.class;

  /* Create a vertical list */
  select name into :nameSQL1-:nameSQL999 
  from sashelp.class;
quit;

 /* same */
data _null_;
  set sashelp.class end=last;
  format nameDS $1000.;
  retain nameDS '';  /* required since we're appending on each loop of sashelp.class */

  nameDS=catx(' ', nameDS, name);
  /* Create a horizontal list */
  if last then call symputx('nameDS', nameDS);

  /* Create a vertical list */
  call symputx(catt('nameDS', _N_), name);

  /* Assign macro variable to total number of names (or just use &SQLOBS) */
  if last then call symputx('cntDS', _N_);
run;

%put _user_;
