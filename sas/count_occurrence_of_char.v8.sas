options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count_occurrence_of_char.v8.sas
  *
  *  Summary: Count characters occurring in a string (v9 does it w/ a function)
  *
  *  Created: Tue 30 Jan 2007 08:28:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data _null_;
  s='count, the commas, in this string';
  l1=length(s);
  s=compress(s, ',');
  l2=length(s);
  n=l1-l2;
  put 'removed ' n= 'commas' ;
run;


 /* or */


%macro Num_Occur(s, findchar);
  %global NUM;
  data _null_;
    l1=length("&s");
    s=compress("&s", "&findchar");
    l2=length(s);
    n=l1-l2;
    call symput('NUM', n);
  run;
%mend;
%Num_Occur(%str(count, the commas, in this string), ',');
%put &NUM;

