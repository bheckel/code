/* Mock dataset standing in for a real table -- exercises %HasLowNumObs
   against a small WORK dataset instead of the author's sashelp.shoes example. */
data small_ds;
  input id name $;
  cards;
1 alpha
2 beta
3 gamma
;
run;

%macro HasLowNumObs(ds, warncnt);
  %let dsid=%sysfunc(open(&ds)); 
  %let cnt=%sysfunc(attrn(&dsid, NOBS)); 
  %let rc=%sysfunc(close(&dsid));
  %if &cnt lt &warncnt %then
    %put uhoh: &cnt;
  %else
    %put ok;
%mend;
%HasLowNumObs(small_ds, 100);
