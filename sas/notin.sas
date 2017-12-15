options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: notin.sas (s/b symlinked as macro.in.sas)
  *
  *  Summary: Emulate the not-available-in-macro function IN and NOT IN
  *
  *  Created: Wed 03 Sep 2003 10:45:00 (Bob Heckel)
  * Modified: Tue 20 Jan 2004 11:35:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro IsIn;
  %do i=1 %to 10;
    %if %sysfunc(indexw(2 3, &i)) %then
      %do;
        %put !!! ok&i is IN;
      %end;
  %end;
%mend;
%IsIn


%macro NotIn;
  %do i=1 %to 10;
    %if not %sysfunc(indexw(4 8 9, &i)) %then
      %do;
        %put !!! ok&i is NOT IN;
      %end;
  %end;
%mend;
%NotIn


 /* The 'NOT IN' feature is not available in macro, so use this instead */
%macro NotInAlpha(state);
  %if not %sysfunc(indexw(AK AR VI WV, &state)) %then
    %do;
      %put !!! alpha &state is NOT IN the list of states;
      data _null_; abort; run;
    %end;
  %else
    %put !!! alpha &state is one of the states in the list;
%mend;
%NotInAlpha(AR);


%macro MakeList(start, n);
  %local i;
  %global lst;

  %do i = &start %to &n;
    %let lst = &lst &i;
  %end;
%mend MakeList;
%MakeList(2,5);


%macro IsComplexIn;
  %local i;
  %do i=1 %to 10;
    %if %sysfunc(indexw(&lst, &i)) %then
      %do;
        %put !!! complex ok&i is IN;
      %end;
  %end;
%mend;
%IsComplexIn

