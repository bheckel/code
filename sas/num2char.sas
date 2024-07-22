options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: num2char.sas
  *
  *  Summary: Convert numeric to character (mnemonic put num both 3 chars)
  *
  *   PUT(name, $10.);       ‘Richard’  ‘Richard   ’
  *   PUT(age, 4.);          30         ‘  30’
  *   PUT(name, $nickname.); ‘Richard’  ‘Rick’
  *   INPUT(agechar, 4.);    ‘30’       30
  *   INPUT(agechar, $4.);   ‘30’       ‘  30’
  *   INPUT(cost, comma7.);  ‘100,541’  100541
  *
  *   See also char2num.sas
  *
  *  Created: 18-Nov-2013 (Bob Heckel)
  * Modified: 11-Jul-2024 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  x=5.1; output;
  x=5; output;
run;
title 'before'; proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;

data t(drop=TMP:);
  set t(rename=(x=TMPx));
/***  x=put(TMPx, F8.1 -L);***/
  /* same */
  x=put(TMPx, BEST. -L);
run;
title 'after'; proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;


data forecast.kmc_renewal_forecast_alloc(drop=acct_id);
  set forecast.kmc_renewal_forecast_alloc;
  acct_id2 = put(acct_id, BEST. -L);
  rename acct_id2=acct_id;
run;
