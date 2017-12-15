/*----------------------------------------------------------------------------
 *     Name: convert_to_millions.sas
 *
 *  Summary: Use array, _numeric_, exponent demo from "SAS Programming".
 *
 *  Created: Wed Jun 02 1999 16:34:28 (Bob Heckel)
 * Modified: Fri 11 Sep 2009 13:45:00 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

/* Dummy ds. */
data work.demo;
  infile cards missover;
  input idnum $  name $  qtr1-qtr4;
  cards;
aaa Rearden 10 12 14 20
bbb Taggart . . 10 10
ccc Galt 22 14 3 25
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /*
data convert(drop=i);
  set work.demo;
  array nums[*] _numeric_;
  do i=1 to dim(nums);
    nums[i] = 1E6 * (nums[i]);
  end;
run;
 */

 /* Better */
data convert;
  set demo;
  array nums _numeric_;
  do over nums;
    nums=nums*1E6;
  end;
run;

proc print data=work.convert noobs;
  /* The '12' includes the commas themselves. E.g. comma6.-- would show commas 
   * only in the 3(000000) observation, the others would be too large and
   * would show no commas.
   */
  format _numeric_ comma12.;
run;
