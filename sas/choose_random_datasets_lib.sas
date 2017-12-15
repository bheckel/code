options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: choose_random_datasets_lib.sas
  *
  *  Summary: Randomly select datasets in a library for QA purposes.
  *
  *  Created: Wed 31 Jan 2007 08:39:51 (Bob Heckel)
  * Modified: Mon 26 Nov 2012 09:20:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/***libname l ('.', 'c:/temp');***/
libname l (
/***  'c:/datapost/data/GSK/Zebulon/MDI'***/
/***  'c:/datapost/data/GSK/Zebulon/MDPI'***/
/***  'c:/datapost/data/GSK/Zebulon/MDPI/AdvairDiskus'***/
/***  'c:/datapost/data/GSK/Zebulon/MDPI/SereventDiskus'***/
/***  'c:/datapost/data/GSK/Zebulon/SolidDose'***/
  'c:/datapost/data/GSK/Zebulon/SolidDose/Bupropion'
  'c:/datapost/data/GSK/Zebulon/SolidDose/Lamictal'
  'c:/datapost/data/GSK/Zebulon/SolidDose/Methylcellulose'
  'c:/datapost/data/GSK/Zebulon/SolidDose/Valtrex'
  'c:/datapost/data/GSK/Zebulon/SolidDose/Wellbutrin'
  'c:/datapost/data/GSK/Zebulon/SolidDose/Zyban'
);


proc sql NOPRINT;
  create table dic as
  select memname, libname
  from dictionary.members
  where libname eq 'L' /*and memname like '%SUM%'*/
  ;
quit;

/***proc surveyselect n=3 data=dic out=dic; run;***/
proc surveyselect n=1 data=dic out=dic; run;

proc sql NOPRINT;
  select compress(libname)||'.'||compress(memname) into :DS separated by ' '
  from dic
  ;
quit;
%put _all_;

 /* If choose >1 ds in surveyselect */
/***data v / view=v;***/
/***  set &DS;***/
/***run;***/
/***proc print data=_LAST_(obs=5); run;***/

 /* If choose exactly 1 ds in surveyselect */
proc freq data=&DS; run;
