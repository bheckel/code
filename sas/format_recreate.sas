options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: format_recreate.sas
  *
  *  Summary: Reverse-engineer SAS code using existing permanent SAS formats 
  *
  * Adapted: Mon Nov 22 12:25:05 2004 (Bob Heckel -- Tim Braam
  *                                    timothy.j.braam@census.gov)
  * Modified: Thu 12 Sep 2013 09:52:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro RebuildFormat(mylib, myfm, mysascode);
  %local myfmt;
  %let myfmt=%sysfunc(compress(&myfm,'$'));

  proc format lib=&mylib
              cntlout=work.ofmt(where=(upcase(fmtname)=upcase("&myfmt")));
  run;

  data work.ofmt;   
    length label $50;
    set work.ofmt;
    start=trim(left(start));
    end=trim(left(end));
    label=trim(left(label));
    if index(label, '.') then label='['||trim(label)||']';
  run;

  proc sort data=work.ofmt nodupkey;
    by start end label;
  run; 

  %if &mysascode ne  %then %do;
    filename OUTF "&mysascode";  /* SAS program to create format.sas7bcat */
  %end;

  data _null_;
    length label $50 prefix $10;

    %if &mysascode ne  %then
      %do;
        file OUTF;
      %end;
    %else
      %do;
        file PRINT;
      %end;

    set work.ofmt  end=last;
    if _N_=1 then 
      do;
        put 'libname FMTLIB ".";';
        put "proc format lib=&mylib;";

        if type = 'P' then 
          put "picture " "&myfmt";
        else if type='C' then 
          put "value " "$&myfmt";
        else if type='I' then 
          put "invalue " "&myfmt";
        else if type='J' then 
          put "invalue " "$&myfmt";
        else put "  value " "&myfmt";
      end;
   if not index(label,'[') then 
     label='"'||trim(left(label))||'"';
   if index(upcase(start),'*OTHER*') then 
     start=compress(start,'*');
    if index(upcase(end),'*OTHER*') then 
      end=compress(start,'*');
   if type ne 'N' then 
     do;
       if upcase(start) ^= 'OTHER' then start='"'||trim(left(start))||'"';
       if upcase(end) ne 'OTHER' then end='"'||trim(left(end))||'"';
     end;
    if upcase(start) ^= 'OTHER' then 
      put start ' - ' end '= ' label;
   else put start '= ' label;
   if type='P' then 
     do;
       put '(mult=' mult best12.;
       if prefix ^='' then do;
         prefix='"'||trim(left(prefix))||'"';
         put 'prefix=' prefix;
       end;
       put ')';
     end;
   if last then 
     do;
       put ';';
       put 'run;';
     end;
  run;
%mend;


options fmtsearch=(FMTLIB);
 /* Location of the mysterious, unrebuildable,  formats.sas7bcat: */
/***libname FMTLIB "DWJ2.NAT2003.FMTLIB" DISP=SHR WAIT=30;***/
libname FMTLIB "c:/datapost/code";

 /* No trailing dot! */
/***%RebuildFormat(FMTLIB, $V012A);***/
%RebuildFormat(FMTLIB, $SQLSDTT);
 /* DEBUG - lst displays the code needed to recreate the format */

/***%RebuildFormat(FMTLIB, $SQLSDTT, t.sas);***/
 /* t.sas should now exist in PWD */

