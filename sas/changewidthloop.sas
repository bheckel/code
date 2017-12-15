options NOcenter;

%global EVT;
***%let EVT=MIC;
***%let EVT=MED;
***%let EVT=FET;
***%let EVT=MOR;
%let EVT=NAT;

LIBNAME BOBH "BQH0.SASLIB" DISP=OLD WAIT=250;


%macro m;
  %do i=3 %to 4;
    libname MAST "DWJ2.REGISTER.&EVT.200&i" DISP=OLD WAIT=20;
    data BOBH.history&EVT.0&i.bkup;
      set MAST.history;
    run;
    data MAST.history (rename=(processed_by=PROCESSED_BY));
      length PROCESSED_BY $10;
      set MAST.history;
    run;
    proc contents data=MAST.history; run;
  %end;
%mend;
%m
