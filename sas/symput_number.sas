options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: symput_number.sas
  *
  *  Summary: Demo of converting a number to a macrovariable.
  *
  *  Adapted: Thu 29 May 2003 08:22:12 (Bob Heckel -- Phil Mason Tips email)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  my_val=12345;
  call symput('value0',my_val);  * auto conversion done;
  call symput('value1',trim(left(put(my_val,8.))));  * v8;
  ***call symputx('value2',my_val);  * SAS 9;
  put _ALL_;
run;

data _NULL_;
  put "&value0 &value1";
run;
