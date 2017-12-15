options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: informat.custom.sas
  *
  *  Summary: Roll your own informat when SAS doesn't provide one.
  *
  *   Sometimes this is better (e.g. 2012-10-31T01:25:08.997-04:00) or 
  *   required since there's no way to do milliseconds:
  *    dt=mdy(substr(dtSplTakenTime,6,2),substr(dtSplTakenTime,9,2),substr(dtSplTakenTime,1,4));
  *     t=hms(substr(dtSplTakenTime,12,2),substr(dtSplTakenTime,15,2),substr(dtSplTakenTime,18,2));
  *
  *  Adapted: Tue 20 Nov 2012 14:29:28 (Bob Heckel--Chakravarthy SUGI 27 101-27)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Targeting 2002/APR/12 */

proc format;
  picture TEMP low-high = '%Y/%b/%d' (datatype=date);
run;

data infmt;
  retain fmtname 'YYYYMD' type 'I';
  do label = '01jan1899'd to '01jan2100'd;
/***    start = put(label, TEMP11.);***/
/***    start = trim(left(start));***/
    start = trim(left(put(label, TEMP11.)));
    output;
  end;
run;
proc print data=_LAST_(obs=5) width=minimum; run;

proc format cntlin=infmt; run;

data _null_;
  txtdt = '2001/APR/17';
  sasdt = input(txtdt, YYYYMD.);
  put sasdt= DATE9.;
run;

