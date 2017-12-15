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
  *  Created: Mon 18 Nov 2013 14:19:58 (Bob Heckel)
  * Modified: Mon 19 Dec 2016 10:51:08 (Bob Heckel)
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
