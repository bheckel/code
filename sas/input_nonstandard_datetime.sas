options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_nonstandard_datetime.sas
  *
  *  Summary: Read in date and time info that is not in the usual SAS
  *           '21MAY98:02:30:59'DT format.
  *
  *           See also character2SASdate.sas
  *
  *  Created: Mon 26 Jan 2009 14:23:37 (Bob Heckel)
  * Modified: Mon 21 Jun 2010 13:23:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Easy - SAS standard datetime */
data t;
  input dtm DATETIME18.;
  cards;
06JUN2008:09:36
07jul2000:04:15:00
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;


 /* Not easy - non-standard */
data t2;
  input dtm $16.;
  cards;
06/10/2008 09:36
  ;
run;
proc contents; run;


data t3(rename=(fmtd=dtm) drop= dtmTMP m d y dt t h mi);
  format fmtd DATETIME18.;
  length m $ 2;
  set t2(rename=(dtm=dtmTMP));
  m = scan(dtmTMP, 1, ' /');
  /* These need length statements to avoid this error: */
  /* INFO: Character variables have defaulted to a length of 200 at the places given by: (Line):(Column). Truncation may result. */
  d = scan(dtmTMP, 2, ' /');
  y = scan(dtmTMP, 3, ' /');
  dt = mdy(m,d,y);

  t = scan(dtmTMP, 4, ' /');
  h = scan(t, 1, ':');
  mi = scan(t, 2, ':');

  fmtd = dhms(dt, h, mi, 0);

  put _ALL_;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;
