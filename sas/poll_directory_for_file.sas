
  %if %sysfunc(fileexist('/Drugs/TMMEligibility/WinnDixie/ExternalFile/PE/*.csv')) %then %do;
    %put  is there;
  %end;
  %else %do;
    %put  is not there;
  %end;



%macro Poll(dir, fn);
  %if %sysfunc(fileexist("&dir\&fn")) %then %do;
    %put &dir\&fn is there;
  %end;
  %else %do;
    %put &dir\&fn is not there;
  %end;
%mend;
%Poll(c:\temp, foo.txt);
