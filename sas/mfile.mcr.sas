options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: mfile.mcr.sas
  *
  *  Summary: Macro to debug resolved macro code.
  *
  *  Adapted: Sat 03 Jun 2006 10:36:09 (Bob Heckel -- Phil Mason email)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


%macro Capture_mprint;
  filename mprint 'c:\mprint.sas';
  options mprint mfile;
%mend Capture_mprint;


%macro Close_mprint;
/***  filename mprint;***/
  dm 'fslist "c:\mprint.sas"' fslist;
%mend Close_mprint;


%macro Test(x);
  %if &x=1 %then
    %do;
      data _null_;
      run;
    %end;
  %else
    %do;
      proc print data=sashelp.class;
      run;
    %end;
%mend Test;


%Capture_mprint;
%Test;
%Close_mprint;
