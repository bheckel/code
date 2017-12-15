options ls=80;

 /* One line explanations. */
proc options; run;

 /* Not too useful. */
***proc options value; run;

 /* Longer explanations and current values. */
***proc options define value; run;
***proc options option=caps define value; run;

 /* Description of a group of options. */
***proc options group=errorHandling;
***run;

 /* Description of a single option. */
***proc options option=mlogic;
***run;

 /* Alternate */
proc sql;
  select *
  from DICTIONARY.options
  ;
quit;
