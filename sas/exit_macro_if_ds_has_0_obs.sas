
%macro m;
/***  %let ds=sashelp.shoes;***/
  %let ds=shoes;  /* fails if dataset doesn't exist at all */
  %let dsid=%sysfunc(open(&ds)); %let cnt=%sysfunc(attrn(&dsid, NOBS)); %let rc=%sysfunc(close(&dsid)); %if &cnt eq 0 %then %do; %goto EXIT; %end;
  %put !!!there are >0 obs (&cnt);
%EXIT:
%mend;
%m;
