%macro HasLowNumObs(ds, warncnt);
  %let dsid=%sysfunc(open(&ds)); 
  %let cnt=%sysfunc(attrn(&dsid, NOBS)); 
  %let rc=%sysfunc(close(&dsid));
  %if &cnt lt &warncnt %then
    %put uhoh: &cnt;
  %else
    %put ok;
%mend;
%HasLowNumObs(sashelp.shoes, 100);
