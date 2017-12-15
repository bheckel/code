
%macro ismvarempty(checkme);
  %if %superq(checkme)=  %then %do;
    %global checkme;
    %let checkme=bar;
  %end;
  %put &checkme;
%mend;
/***%ismvarempty(foo);***/
%ismvarempty();
