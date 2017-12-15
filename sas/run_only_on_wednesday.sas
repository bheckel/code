
%macro import_imm_common;
  %put !!!%sysfunc(weekday("&SYSDATE"d));

  %if %sysfunc(weekday("&SYSDATE"d)) eq 4 %then %do;
    %put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
    %put NOTE: start import_imm_common.sas;
    %put NOTE: %sysfunc(getoption(SYSIN)) started: %sysfunc(putn(%sysfunc(datetime()),DATETIME.));
    %put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;

  %end;
  %else %do;
    %put import_imm_common.sas only runs on Wednesday;
  %end;
%mend import_imm_common;
%import_imm_common;
