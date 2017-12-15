
data t;
  input num ch $CHAR8.;
  cards;
123456 abc
123456 DEADBEEF
  ;
run;
proc print;
/***  format num DATE9.;***/
/***  format num HEX12.;***/
/***  format ch $QUOTE.;***/
/***  format ch $REVERS32767.;***/
  format num MMDDYY8.;
run;
