options NOxwait;

%let D=C:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets\OUTPUT_COMPILED_DATA;
 /* SAS uses lowercase, we want uppercase 'AND' */
data _NULL_;
  rc=system("move &D\valtrex_productionandanalytical.sas7bdat &D\valtrex_productionANDanalytical.sas7bdat");
  put _all_;
run;
