options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: generate_range.sas
  *
  *  Summary: Generate a sequence of delimited numbers or letters based on 
  *           a given dash-separated range.
  *
  *           Used by the SAS IntrNet Web Query System.
  *
  *  Created: Mon 23 Jun 2003 15:34:16 (Bob Heckel)
  * Modified: Wed 09 Jul 2008 09:46:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer;

 /* Accepts:   a string (e.g. 1-5 or A-D) and the delimiter char to use on the
  *            parsed string
  *
  * "Returns": &range, the delimited individual elements of the requested
  *            range
  */
%macro GenerateRange(rng, delim);
  %global range;
  %local i j lo hi isnumlo isnumhi;

  %let lo=%qscan(&rng, 1, '-');
  %let hi=%qscan(&rng, 2, '-');

  %let isnumlo = %verify(&lo, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
  %let isnumhi = %verify(&hi, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

  %if &isnumlo ne &isnumhi %then
    %do;
      %put !!! ERROR: bad range: LO &isnumlo  HI &isnumhi;
      data _NULL_; abort abend 008; run;
    %end;

  /* Convert received chars to their ASCII representation in order to loop */
  %if &isnumlo eq 0 %then
    %do;
      %let lo=%sysfunc(rank(&lo));
      %let hi=%sysfunc(rank(&hi));
    %end;

  %do i=&lo %to &hi;
    %if &i eq &lo %then
      /* We're working with ASCII values which have to convert back to chars */
      %if &isnumlo eq 0 %then
        %let range = %sysfunc(byte(&i));
      /* We're working with simple numbers */
      %else
        %let range = &i;
    %else
      %if &isnumlo eq 0 %then
        %do;
          /* Convert back to char */
          %let j = %sysfunc(byte(&i));
          %let range = &range.&delim.&j;
        %end;
      %else
        %let range = &range.&delim.&i;
  %end;
%mend GenerateRange;
/***%GenerateRange(2-5, %str(,))***/
%GenerateRange(B-F, %str(,)) 

%put !!! expanded string is: &range;
