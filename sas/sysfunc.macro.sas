options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sysfunc.macro.sas (also see datasetexist.sas)
  *
  *  Summary: Allows access by the macro processor to most data step 
  *           functions.
  *           
  *           Functions available to %sysfunc
  *
  *           All data step functions are available except:
  *           DIF INPUT PUT DIM LAG RESOLVE HBOUND LBOUND SYMGET
  *
  *           Instead of INPUT and PUT you can use INPUTC, INPUTN and PUTC,
  *           PUTN for character or numeric formats, respectively.
  *
  *  Adapted: Mon 28 Jun 2004 17:17:36 (Bob Heckel --
  *                                 http://www.cyassociates.com/sysfunc.htm)
  * Modified: Mon 28 Apr 2008 09:11:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


%let dt=600131;
 /* TODO why must use inputn instead putn? */
%put !!!SAS days-since-the-epoch: %sysfunc(inputn(&dt, YYMMDD6.));


 /* Caution, number in DOLLARn (or COMMAn, etc.) must be wide enough. */
%let num=1234567;
%put !!!dollars: %sysfunc(putn(&num, DOLLAR10.));


%let state=1;
proc format;
  value f_st
    1 = 'NJ' 
    2 = 'NC'
    ;
run;
%put !!!User format: %sysfunc(putn(&state, f_st.));

%macro m;
  /* There's no %not in macro. "!" doesn't work either. */
  %if not %sysfunc(fileexist(&HOME/bladerun_crawl)) %then
    %put file does not exist;
  %else
    %put file exists;
%mend; %m
