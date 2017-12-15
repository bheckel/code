options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_output_excel_mult_worksheet.sas
  *
  *  Summary: Produce a multi-worksheet Excel workbook
  *
  *  Adapted: Fri 16 Oct 2015 15:03:44 (Bob Heckel--SESUGI 2015 CC76)
  * Modified: Tue 07 Feb 2017 13:33:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;


ods excel file="/Drugs/RFD/2017/02/AN-6617/Reports/AN-6617.xlsx";
  ods excel options(sheet_name="6 mo lookback");
  proc print data=output2  NOobs; sum count; run;
  ods excel options(sheet_name="12 mo lookback");
  proc print data=output3  NOobs; sum count; run;
ods excel close;



 /* This is how to find 'Variables' (Attributes & EngineHost also exist but we're
  * not interested):
  */
/***ods trace on;***/
/***proc contents data=sashelp.class; run;***/
/***endsas;***/

ODS OUTPUT Variables=myallvarout;
proc contents data=sashelp._all_ memtype=data; run;

proc sort data=myallvarout;
  by member num;
run;

options nobyline;
ODS EXCEL FILE="/Drugs/Personnel/bob/all_variables_in_SASHELP_data_sets.xlsx" options(sheet_name="#BYVAL(member)" embedded_titles='yes');
proc print data=myallvarout noobs;
  by member;
  pageby member;
  /* 1st line of each Excel worksheet */
  title "Variables in #BYVAL(member) data set";
run;
proc print data=sashelp.cars; run;
ODS EXCEL close;
