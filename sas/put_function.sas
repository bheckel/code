options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: put_function.sas
  *
  *  Summary: Demo of the put function (plus some put statements).
  *
  *  Created: Sun 15 Jun 2003 13:57:21 (Bob Heckel)
  * Modified: Mon 04 Apr 2011 15:19:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc format;
  value f_city 100-200 = 'NE'
               200-300 = 'SW'
               ;
run;

data _NULL_;
  n=4242;
  wn=put(n, 4.);
  put wn=;
  /* Forces SAS Log warning about BEST. */
  ***wn=put(n, F3.1);
  /* Same */
  wn2=put(n, 3.1);
  put wn2=;
  wn3=put(n, 2.1);
  put wn3=;
  /* TODO why doesn't force a zero decimal point? */
  wn4=put(n, 5.1);
  put wn4=;
  put;

  c='character';
  ***wc=put(c, $F4.);
  /* Same */
  wc=put(c, $4.);
  put wc=;
  put;

  d='07jul00'D;  /* date constant */
  put d=;
  dd=put(d, WORDDATE.);
  put dd=;
  /* Same */
  d2=14798;
  dd2=put(d, WORDDATE.);
  put dd2=;
  put;

  decnum=18;
  hexnum=put(decnum, HEX2.);
  put hexnum=;

  city=207;
  /* As an lvalue!  Save effort of having to create a temp variable like
   * 'region'.  E.g. region=put(city, f_city.);
   */
  if put(city, f_city.) = 'SW' then
    put 'ok';

  value = 'wide5678901234567';
  /* Too small */
  designator = put(value, 16.);
  put designator=;
run;
