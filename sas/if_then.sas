 /*---------------------------------------------------------------------------
  *     Name: if_then.sas
  *
  *  Summary: Demo of IF-THEN statment and subsetting IF.
  *
  *           Use a SELECT group rather than a series of IF-THEN statements
  *           when you have a long series of mutually exclusive conditions.
  *
  *           Use %IF to decide whether to GENERATE the code.
  *           Use IF to decide whether to EXECUTE the code.
  *
  *  Created: Tue, 21 Dec 1999 13:03:13 (Bob Heckel)
  * Modified: Tue 12 Aug 2003 13:13:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data t;
  set sashelp.shoes;
  if region eq 'Asia' then put 'As'; else put 'no';

  if region eq 'Africa' then do;
    put 'Af';
  end;
  else do;
    put 'no';
  end;
run;
endsas;


data foo;
  input empid $ 1-6  alias;
  cards;
123num 0
456num .
       0
555num 1
959num 1
  ;
run;
title 'ds foo:';
proc print data=foo (obs= 10); run;
title;


data bar;
  set foo;
    if substr(empid, 1, 1) = '0' then     /* no semi! */
      put '!!! starts with zero';         /* semi!    */
    else if substr(empid, 1, 1) = '9' then 
      put '!!! starts with nine';
    else    /* no semi! */
      /* Best to list conditions in order of decreasing probability. */
      put 'do not know';
run;


data bar2;
  set foo;

  /* Subsetting IF.  Used when it's easier to specify a condition for
   * including observations.  Use DELETE when easier to exclude.
   * It's a sort of on-off switch, if condition is true, switch is on.
   */
  if empid ne '';

  /* Subsetting IF.  Only include alias records that are non-missing,
   * non-zero. 
   */
  if alias;

  %macro bobh;
  /* A verbose alternative to a subsetting IF. */
  if alias = 1 then
    do;
      delete;
      %put !!! deleted alias;
    end;
  %mend;
run;
title 'ds bar2:';
proc print; run;
title;


data _NULL_;
  ***foo = 0;
  foo = 1;

  if not foo then
    put 'foo is not true';
  else
    put foo=;

  ***bar = 'string';
  /* Same as no 'bar = ...' statement. */
  ***bar = '';
  if bar eq '' then
    put 'bar is empty';
  else
    put bar=;
run;



data unused;
  set foo;
  if empid ne '';
  if empid eq: '4' then delete;
  if empid eq: '5' then delete;
run;
title 'ds unused:';
proc print data=unused (obs= 10); run;
title;
