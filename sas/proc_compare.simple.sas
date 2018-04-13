options NOcenter NOreplace;


 /* The two ds must be sorted identically */

***libname OLD 'DWJ2.MOR2004.LIBRARY' DISP=SHR;
/* libname NEW 'BQH0.SASLIB' DISP=SHR; */
libname NEW '/Drugs/Personnel/bob/PQA_NDC_merge/20180403';
***libname OLD '/u/dwj2/mvds/NAT/2003';
***libname OLD 'DWJ2.NAT2003.MVDS.LIBRARY.NEW' DISP=SHR WAIT=1;
/* libname OLD 'DWJ2.USTOT.SASLIB' DISP=SHR WAIT=1; */
libname OLD '/Drugs/Personnel/bob/PQA_NDC_merge/20180319';

/* proc compare base=OLD.ust2003oldnat compare=NEW.ust2003oldnat; */
/* proc compare base=OLD.pqa_ccb compare=NEW.pqa_ccb novalues listvar; */
/* proc compare base=OLD.pqa_ccb compare=NEW.pqa_ccb novalues brief listvar; */
proc compare base=OLD.pqa_copd compare=NEW.pqa_copd novalues brief listbasevar;
proc compare base=OLD.pqa_copd compare=NEW.pqa_copd novalues brief listcompvar;


 /* To compare *format* library catalogs, we must 1st convert to a ds. */


 /* Good to tell if the datasets differ AT ALL, not what the diffs are, to do that use this: */
/* proc export data=l.lims_report_profile OUTFILE='TMPlims_report_profile.csv' DBMS=CSV REPLACE; run; */
/* proc export data=demo.lims_report_profile OUTFILE='TMPdemolims_report_profile.csv' DBMS=CSV REPLACE; run; */



 /* Alternative */

libname oldlib '/Drugs/Personnel/bob/PQA_NDC_merge/20180319' access=readonly;

libname newlib '/Drugs/Personnel/bob/PQA_NDC_merge/20180403' access=readonly;


proc contents data=oldlib._all_ out=old NOprint; run;

proc contents data=newlib._all_ out=new NOprint; run;


title 'on old not on new';
proc sql;
  select upcase(name), memname from old
  EXCEPT
  select upcase(name), memname from new
  ;
quit;

title 'on new not on old';
proc sql;
  select upcase(name), memname from new
  EXCEPT
  select upcase(name), memname from old
  ;
quit;
