options nosource;
 /*---------------------------------------------------------------------------
  *     Name: update.sas
  *
  *  Summary: Demo of updating a ds with new info.
  *
  * A master dataset may be changed by only those variables in it that undergo
  * a change during an interval. The variables that undergo these changes are
  * included in a transaction dataset. What the updating does is to alter the
  * master dataset where there is a change (indicated by a nonmissing value in
  * the transaction dataset). 
  * 
  * The updating process uses only nonmissing values in the transaction data
  * set to alter the master dataset. While updating can change a master data
  * set with a transaction dataset, the merge can combine up to fifty datasets
  * at one time. The updating process requires a by statement whereas the
  * merge does not. 
  *
  *
  *     An SQL-like update and set= approach:
  *
  *     data SASPRESC.prescribers_on_file&sysdate;
  *       set LIBNAME1.t_ref_bpms_prescriber_info;
  *       where plancode = "&plancode";
  *       source = 'old';
  *     run;
  *
  *
  *  Adapted: Tue Jul 13 1999 12:32:08 (Bob Heckel)
  * Modified: Thu 25 Jun 2009 12:55:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.master;
  input city $ 1-8  temp  humid;
  cards;
New York  87 30
Rome      76 29
Albany    70 28
Newark    84 32
  ;
run;
proc print; run;

data work.transacts;
  input  city $ 1-8 temp  humid;
  cards;
New York 90 91
Newark     92 93
Albany      .     .
Rome        .     .
  ;
run;
proc print; run;

proc sort data=master; by city; run;
proc sort data=transacts; by city; run;
data master;
  update master transacts;
  by city;  /* mandatory */
run;
proc print; run;


/* If need to update an existing value in the master ds to missing, must
 * include a 'special missing value' in the transaction ds.
 * E.g. employee doesn't want home address listed in new corp directory.
 * data test;
 *   missing _;
 *   input x $;
 *   cards;
 * blah
 * _
 * blah2
 *   ;
 * run;
 */
