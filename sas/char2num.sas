options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: char2num.sas
  *
  *  Summary: Convert character to numeric.
  *
  *   INPUT(agechar, 4.);    ‘30’       30
  *   INPUT(agechar, $4.);   ‘30’       ‘  30’
  *   INPUT(cost, comma7.);  ‘100,541’  100541
  *
  *   PUT(name, $10.);       ‘Richard’  ‘Richard   ’
  *   PUT(age, 4.);          30         ‘  30’
  *   PUT(name, $nickname.); ‘Richard’  ‘Rick’
  *
  *   See also num2char.sas
  *
  *  Created: 18-Nov-2013 (Bob Heckel)
  * Modified: 11-Jul-2024 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Swap and drop */
data nums;
  set chars(rename=(Height=Char_Height
                    Weight=Char_Weight
                    Date=Char_Date));
  Height = input(Char_Height,8.);
  Weight = input(Char_Weight,8.);
  Date   = input(Char_Date,mmddyy10.);

  drop Char_:;
run;


data forecast.kmc_renewal_forecast_alloc(drop=acct_id);
  set forecast.kmc_renewal_forecast_alloc;
  acct_id2 = input(acct_id, ?? 8.);
  rename acct_id2=acct_id;
run;
