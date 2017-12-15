options NOsource ls=180;
 /*---------------------------------------------------------------------------
  *     Name: locf.sas
  *
  *  Summary: Last observation carried forward.  This example determines
  *           each patient's baseline cholesterol level, defined as the number
  *           recorded just prior to dosing.
  *
  *  Adapted: Fri 19 Oct 2012 14:35:08 (Bob Heckel--Jack Shostak Pharma book)
  * Modified: Thu 03 Nov 2016 14:41:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data labresults;
  format sampdate DATE9.;
  input subject $ sampdate DATE9. hdl ldl trig; 
  datalines;
101 05SEP2003 48 188 108
101 06SEP2003 49 185 .  
102 01OCT2003 54 200 350
102 02OCT2003 52 .   360
103 10NOV2003 .  240 900
103 11NOV2003 30 .   880
103 12NOV2003 32 .   .  
103 13NOV2003 35 289 930
  ; 
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data dosing;
  format dosedate DATE9.;
  input subject $ dosedate DATE9.; 
  datalines;
101 07SEP2003
102 07OCT2003
103 13NOV2003
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc sort data=labresults; by subject sampdate; run;
proc sort data=dosing; by subject; run;
data baseline;
  merge labresults dosing;
  by subject;

  array chol{3}   hdl   ldl   trig;
  array base{3} b_hdl b_ldl b_trig;

  keep subject b_hdl b_ldl b_trig;
  retain b_hdl b_ldl b_trig;

  if first.subject then
    do i=1 to 3;
      base{i} = .;
    end;
	 
   /* If a lab value is within 5 days of dosing, retain it as a valid baseline value.  I.e. this skips lab values that
    * have been taken today or are too old to still be useful.
    */
   if 1 <= (dosedate-sampdate) <= 5 then
     do i=1 to 3;
       if chol{i} ne . then base{i} = chol{i};
     end;

put 'DEBUG: '; if subject eq '103' then put _all_;

   /* Keep last record per patient - these hold the LOCF values */
   if last.subject;

   label b_hdl  = "Baseline HDL"
         b_ldl  = "Baseline LDL"
         b_trig = "Baseline triglicerides";
run;
title 'for patient 102, 01OCT is not within 5 days of 07OCT so cannot carry forward the 200, must set missing';
proc print data=_LAST_(obs=max) width=minimum ; run;
