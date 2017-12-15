options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_fcmp.sas
  *
  *  Summary: Roll your own functions
  *
  *  Adapted: Mon 04 Nov 2013 13:21:18 (Bob Heckel--SUGI 033-2013)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Simple */

proc fcmp OUTLIB=work.functions.demo;
  function my_sum(var1, var2) ;
    if missing(var1) then v1= 0; else v1= var1;
    if missing(var2) then v2= 0; else v2= var2;
    if missing(var1) and missing(var2)
    then sum = .; else sum = v1 + v2;
    return(sum);
  endsub;

  function my_cat(str1 $, str2 $) $;
    length cat $32767;

    cat = trim(str1) || trim(str2);
    tac = trim(str2) || trim(str1);

    if str1 eq 'Africa' then
      return(trim(cat));
    else
      return(trim(tac));
  endsub;
run;

OPTIONS CMPLIB=work.functions;
data t;
  set sashelp.shoes;
  foo = my_cat(region, product);
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;  ***/

 /*~~~~~~~~~~~~~~~~~~~~~~~*/
 
 /* Advanced */

 /* Before */
%macro get_NLevels(dsn, var);
  ods output nlevels=NLevels_out;
  proc freq data=&dsn nlevels;
    tables &var / noprint;
  run;
  data _null_;
    set NLevels_out;
  run;
  proc datasets library = work nolist;
    delete NLevels_out;
  quit;
%mend;

 /* After */
%macro get_NLevels2;
  %let dsn = %sysfunc(dequote(&dsn.));
  %let var = %sysfunc(dequote(&var.));

  ods output nlevels=NLevels_out;
  proc freq data=&dsn nlevels;
    tables &var / noprint;
  run;
  data _null_;
    set NLevels_out;
    call symput('nlevels',NLevels);
  run;
  proc datasets library=work nolist;
    delete NLevels_out;
  quit;
%mend;


 /* Parameters on the RUN_MACRO command represent two-way communication between
  * the function and the macro.
  *
  * So far this is looking a lot like CALL EXECUTE.  the advantage of RUN_MACRO
  * functions is that we have a built-in channel to report back to the calling
  * data set.
  *
  * If the DATA step represents the executive who is giving the instructions,
  * then the underlying macro represents the programmer that actually performs
  * the task. The RUN_MACRO function serves as a middleman, facilitating
  * two-way communication between the calling data set and the macro. Unlike
  * typical macros which generate data sets or output, macros used in RUN_MACRO
  * functions generate information. By extracting values and metrics from the
  * execution of a macro, RUN_MACRO routines give us the capability to answer
  * high-level questions about data sets, variables, and entire analytical
  * processes.
  */
proc fcmp outlib=work.functions.wrapper;
  function nlevels_f(dsn $, var $);
    rc = run_macro('get_NLevels2', dsn, var, nlevels);
    return(nlevels);
  endsub;
run;

OPTIONS CMPLIB=work.functions;
data t;
  set sashelp.vcolumn;
  where libname eq 'SASHELP' and memname eq 'CLASS';
  fqdsn = left(trim(libname))||'.'||left(memname);
  foo = nlevels_f(fqdsn, name);
run;
proc print data=_LAST_(obs=max) width=minimum; run;  

