options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: kilograms_to_pounds.sas
  *
  *  Summary: Convert kg to lb
  *
  *  Adapted: Tue 07 Apr 2015 09:17:00 (Bob Heckel--http://support.sas.com/resources/papers/proceedings14/1204-2014.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input @1 wt $10.;

  wt_lbs = input( compress(wt,,'kd'), 8. );  /* keep decimals */

  if findc(wt, 'k', 'i') then
    wt_lbs = 2.2*wt_lbs;

  cards;
155lbs
90Kgs.
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
