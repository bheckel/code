options nosource;
 /*---------------------------------------------------------------------------
  *     Name: inplace_edit.sas
  *
  *  Summary: Demo of editing an extenal, non-SAS file with SAS.
  *
  *  Created: Sat 25 Jan 2003 17:14:29 (Bob Heckel)
  * Modified: Fri 22 May 2015 15:41:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Update timestamp */
 data _null_;
   infile "wellcare_global_setting.txt" TRUNCOVER SHAREBUFFERS termstr=crlf;
   file "wellcare_global_setting.txt";

   input @1 line $CHAR80.;

   if index(line, 'hp_patient_create_dt') then do;
     x=put(today(), DATE9.);
     put '%let hp_patient_create_dt=' x;
   end;
   else do;
     put _INFILE_;
   end;
 run;


endsas;
filename MYXML "&DPPATH\CODE\_WSIP21.xml";
data _null_;
  infile MYXML TRUNCOVER;
  input @1 test $CHAR80.;
  if test eq: '<NewDataSet />' then do;
    put 'WARNING: Query returned no results, empty XML file exists.';
    file MYXML;
    put '<NewDataSet><Table><Name></Name><Ts></Ts><Value></Value></Table></NewDataSet>';
  end;
run;


endsas;
 /* Assume 'junk' looks like this: 
1
22
333
4444
55555
 */

filename IN 'junk';
filename OUT 'junk';

data tmp;
  infile IN TRUNCOVER;
  input @1 block $80.;
run;


data _NULL_;
  set tmp;
  file OUT;
  block=tranwrd(block, '333', 'XXX');
  put @1 block $80.;
run;


endsas;
  /* TODO not working - won't write the 2nd file with 999;
filename one 'junk';
filename two 'junktmp';

data _null_;
  /*             efficient              */
  infile one SHAREBUFFERS TRUNCOVER;
  ***file two;
  input num;
  if num eq 1 then
    num=999;
  /* Put the entire line, including the changes. */
  put _INFILE_;
run;


***x 'rename junktmp junk';
