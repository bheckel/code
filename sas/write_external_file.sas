options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: write_external_file.sas
  *
  *  Summary: Write an external textfile.
  *
  *  Created: Mon 02 Oct 2006 15:29:12 (Bob Heckel)
  * Modified: Thu 23 Jul 2015 13:08:42 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

ods listing file='u:/sgk/zerorecs.txt';
  proc print data=_LAST_(obs=max) width=minimum;
    var prod_brand_name cb0 cb1;
  run;
ods listing;



 /* Update Task timestamp */
%local FILERECDATE;
data _null_;
  set MOYA.new_status_to_insert;
  call symput('FILERECDATE', filerecdate);
run;

data _null_;
  infile "/Dgs/Kelly/humana/humana_global_setting.txt" TRUNCOVER SHAREBUFFERS termstr=crlf;
  file "/Dgs/Kelly/humana/humana_global_setting.txt";

  input @1 line $CHAR80.;

  if index(line, 'hp_patient_create_dt') then do;
    x=put(&FILERECDATE, DATE9.);
    put '%let hp_patient_create_dt=' x;
  end;
  else do;
    put _INFILE_;
  end;
run;



filename CITY '!TEMP/city.dat';
data _null_;
  infile cards missover length=l;
  length text $ 50;
  input text $varying50. l;
  file CITY pad lrecl=28;
  put text;
  datalines;
ANCHORAGE 48081 174431
BOSTON 641071 562994
CHARLOTTE 241420 314447
MIAMI 334859 346865
PHILADELPHIA 1949996 1688210
SACRAMENTO 257105 275741
  ;
run;



filename F '!TEMP/junk.dat';
data _null_;
  set sashelp.shoes;
  file F;
/***  put _all_;***/
  put region 'and ' product;
run;



data _null_;
  file 'c:\temp\extfile1.txt';
  put "05JAN2001 6 W12301 1.59 9.54";
  put "12JAN2001 3 P01219 2.99 8.97";
run;



data _null_;
  file "&DIRROOT.ErrorFlag.txt";
  put @1 "&ds: &cnt";
run;
