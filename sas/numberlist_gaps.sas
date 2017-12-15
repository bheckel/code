options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macro.list.sas
  *
  *  Summary: Generate a list of numbers, optionally with 
  *           breaks in the series, ie gaps.
  *
  *  Created: Thu 02 Oct 2003 10:10:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro MakeList(lo, hi);
  %local i;
  %global lst;

  %do i = &lo %to &hi;
    %let lst = &lst &i;
  %end;
%mend MakeList;
***%MakeList(2,5);
***%put !!! simple &lst;


%macro GapSeries;
  %global gaps;

  %MakeList(2,4);
  %MakeList(5,5);
  %MakeList(7,9);
  %let gaps = &gaps &lst;
%mend GapSeries;
%GapSeries;
%put !!! complex with gaps &gaps;
