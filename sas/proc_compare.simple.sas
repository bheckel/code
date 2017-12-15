options NOcenter NOreplace;


 /* The two ds must be sorted identically */

***libname OLD 'DWJ2.MOR2004.LIBRARY' DISP=SHR;
libname NEW 'BQH0.SASLIB' DISP=SHR;
***libname OLD '/u/dwj2/mvds/NAT/2003';
***libname OLD 'DWJ2.NAT2003.MVDS.LIBRARY.NEW' DISP=SHR WAIT=1;
libname OLD 'DWJ2.USTOT.SASLIB' DISP=SHR WAIT=1;

proc compare base=OLD.ust2003oldnat compare=NEW.ust2003oldnat;


 /* To compare *format* library catalogs, we must 1st convert to a ds. */


 /* Good to tell if the datasets differ AT ALL, not what the diffs are, to do that use this: */
proc export data=l.lims_report_profile OUTFILE='TMPlims_report_profile.csv' DBMS=CSV REPLACE; run;
proc export data=demo.lims_report_profile OUTFILE='TMPdemolims_report_profile.csv' DBMS=CSV REPLACE; run;
