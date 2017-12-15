 /*---------------------------------------------------------------------------
  *     Name: input_colon.sas
  *
  *  Summary: Demo of using : (colon modifier qualifier) in "modified list
  *           input" style input statements.
  *
  *           ':' indicates that the value is to be read from the next
  *           non-blank col until the pointer reaches the NEXT BLANK COLUMN
  *           OR THE END OF THE DATA LINE, whichever comes first.  Though
  *           the pointer continues READING until it reaches the next blank
  *           col, it TRUNCATES the value of a character variable if the
  *           field is longer than its formatted length.
  *
  *           Compare compile-time:
  *           "Formatted input" informat determines both the length and the
  *           (same) number of columns to be read.
  *           This "modified list input" determines only the length.
  *
  *           Default is space, use DLM= to change to comma, etc.
  *           data t; infile F DLM=',' DSD MISSOVER LRECL=2600 FIRSTOBS=3; input Product :$40. ... ; run;
  *
  *  Created: Wed, 24 Nov 1999 13:25:29 (Bob Heckel)
  * Modified: Mon 20 Mar 2017 10:33:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
 
data FUNCDATA.tmm_targeted_list_refresh;
  format initialized_date lastbuild_date lastimport_date DATE9.;
  infile cards TRUNCOVER;
  input clid
        is_independent
        is_redpoint
        is_onhold
        initialized_date :DATE9.
        run_code :$40.
        refresh_cycle_days
        lastbuild_date :DATE9.
        lastimport_date :DATE9.
        qc_notes $100.
        ;
  cards;
123 0 0 0 01JAN2017 %tx 14 02JAN2017 07JAN2016 
965 1 0 0 19MAR2017 %tx 21 27FEB2017 28FEB2017 low age pct
456 0 0 0 19MAR2017 %tx 21 27FEB2017 01MAR2017 low age pct testing
;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

endsas;


data work.tmp;
  /* $11. is a MAXIMUM when preceded by ':'
   *
   *           This is NOT the same as specifying a numeric informat with
   *           formatted input!  There you would need to specify the w in COMMAw.d
   *           Not needed here since default numeric is 8.
   *                                 _____________
   */
  input anum  ssnstring :$11.  nickname $  salary :COMMA.  position $3.;
  datalines;
123 134-56-9094x Megan 45,000 serf
123 160-58-1223 Kathrynnn 47,000,123 serf2
123 161-60-5881 Joshua 46000 drone
123 123-45-6 Bob 10,000 drone2
  ;
run;
proc print; run;

title "But it fails without ':' specifier";
data work.tmp2;
  input ssnstring $11. nickname $  salary COMMA.  position $3.;
  datalines;
134-56-9094x Megan 45,000 serf
160-58-1223 Kathrynnn 47,000,123 serf2
161-60-5881 Joshua 46000 drone
123-45-6 Bob 10,000 drone2
  ;
run;
proc print; run;

title "So try the verbose method";
data work.tmp2;
  informat ssnstring $12.  salary COMMA.;
  input ssnstring  nickname $  salary  position $3.;
  datalines;
134-56-9094x Megan 45,000 serf
160-58-1223 Kathrynnn 47,000,123 serf2
161-60-5881 Joshua 46000 drone
123-45-6 Bob 10,000 drone2
  ;
run;
proc print; run;
endsas;


title "This is one (less obfuscated but less concise) way around it";
data work.tmp2;
  length ssnstring $11;
  informat salary COMMA.;
  input ssnstring $  nickname $  salary $  position $;
  datalines;
134-56-90949 Megan 45,000 serf
160-58-1223 Kathryn 47,000 serf2
161-60-5881 Joshua 46000 drone
123-45-6 Bob 10,000 drone2
  ;
run;
proc print;
  var ssnstring nickname salary position;
run;



filename envcmd PIPE 'set' lrecl=1024;
data xpset;
  infile envcmd dlm='=' MISSOVER;
  /* These next two lines are the same as the one line using the colon approach */
  ***length name $32 value $80;
  ***input  name $   value $;
  input name :$32. value :$80.;
run;



/*
H9999999999,ALNAME,AFNAME,M,1/1/1901,99 S FOO RD,,ARLING,VA,22206,9999999999,1,GIANT PLACECY 748 - ARLING,999 SOUTH LEBE ROAD,ARLING,VA,22206,,ATORVASTATIN CALCIUM TAB 20 MG (BASE EQUIVALENT),Hyperlipidemia,0,0,99999999,999999999
*/
data t;
  infile FROMHP DLM=',' DSD MISSOVER lrecl=2600 firstobs=2;
  format Patient_DOB DATE9.;
  input Cardholder_ID :$40.
        Patient_Last_Name :$64.
        Patient_First_Name :$64.
        Patient_Gender :$1.
        Patient_DOB :MMDDYY10.
        Patient_address_field_1 :$64.
        Patient_address_field_2 :$64.
        Patient_city :$32.
        Patient_state :$2.
        Patient_zip :$10.
        Target_Pharmacy_ID :$15.
        Target_Pharmacy_ID_Qualifier :$40.
        Target_Pharmacy_Name :$64.
        Target_Pharmacy_Address :$64.
        Target_Pharmacy_City :$32.
        Target_Pharmacy_State :$2.
        Target_Pharmacy_Zip :$10.
        Prescription_Reference_Number :F12.  /* num to eliminate leading zeros */
        Drug_Name :$80.
        Drug_Class :$80.
        Not_In_Play :F2.
        No_Longer_Enrolled :F2.
        Effective_Date :$40.
        Drug_NDC :$80.
        ;
  Patient_zip3 = substr(Patient_zip, 1, 3);
  Target_Pharmacy_Zip3 = substr(Target_Pharmacy_Zip, 1, 3);
  PRN_char = put(Prescription_Reference_Number, F10. -L);
  CHID_char = put(Cardholder_ID, F12. -L);
 
  call symput('NUMRECS', _N_);
run;
