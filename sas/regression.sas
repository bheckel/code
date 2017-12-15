
%macro regress(platform, prd);
  %if &platform eq DEV %then %do;
    libname x "C:\cygwin\home\bheckel\projects\datapost\tmp\&prd\OUTPUT_COMPILED_DATA";
  %end;

  %if &platform eq PRD %then %do;
    libname x "\\rtpsawnv0312\pucc\&prd\OUTPUT_COMPILED_DATA";
  %end;

  proc printto PRINT="C:\cygwin\home\bheckel\projects\datapost\tmp\&prd\CODE\util\regress&platform..&SYSDATE..lst" NEW; run; 

  proc freq data=x.venhfa_analytical_individuals;run;
  proc freq data=x.venhfa_analytical_summary;run;
  proc freq data=x.venhfa_productionall;run;
  proc freq data=x.venhfa_productionandanalytical;run;

  proc printto;run;
%mend;
%regress(DEV, Ventolin_hfa)
/***%regress(PRD, Ventolin_hfa)***/
 /* Then diff them */
