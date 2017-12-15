
%macro MvarExist;
  /* %let checkme=x; */  

  %if not %symexist(checkme) %then %do;
    %put !!!macrovariable does not exist;
  %end;
  %else %do;
    %put !!!exists;
  %end;
%mend;
%MvarExist
