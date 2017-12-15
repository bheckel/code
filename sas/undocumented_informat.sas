options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: undocumented_informat.sas
  *
  *  Summary: V8 does not list this but it is available, appears in V9
  *
  *  Adapted: Fri 06 May 2011 08:15:34 (Bob Heckel--http://support.sas.com/kb/15/803.html)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data _null_;
  x='2005/6/30 12:30';
  y='6/30/2005 12:30am';
  z='2005/6/30 12:30am';
  a='6/30/2005 12:30';

  ymd_no_ampm=input(x, YMDDTTM16.);
  mdy_ampm=input(y, MDYAMPM18.);
  ymd_ampm=input(z, ?? YMDDTTM18.);
  mdy_noampm=input(a,MDYAMPM16.);

/***  put (ymd_no_ampm mdy_ampm ymd_ampm mdy_noampm)(= DATEAMPM. /);***/
  put (ymd_no_ampm mdy_ampm ymd_ampm mdy_noampm)(= DATETIME18.);
run;
