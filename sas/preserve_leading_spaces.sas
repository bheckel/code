options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: preserve_leading_spaces.sas
  *
  *  Summary: How to preserve leading whitespace (strange that this
  *           abomination is required and not a simple $CHARn.) when
  *           'put'ing.
  * 
  * Adapted: Fri Jun 18 16:44:12 2004 (Bob Heckel --
  * http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&th=20339310fce3e5a1&rnum=5)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* junkin.txt contents:
abc                bob
def                bob2
 */
filename IN 'junkin.txt';
filename OUTBAD 'junkbad.txt';
filename OUTGOOD 'junkgood.txt';

 /*******/
data danger;
  infile IN TRUNCOVER;
  input @1 foo $CHAR3.  @15 bar $CHAR20.;
run;

data _null_;
  set danger;
  file OUTBAD;
  if _n_ eq 1 then
    put 'simple but does not retain 5 leading spaces';

  put @1 foo  @50 bar;
run;
 /*******/

 /*******/
data safe (drop= bar);
  infile IN TRUNCOVER;
  input @1 foo $CHAR3.  @15 bar $CHAR20.;
  outbar = put(bar, $CHAR.);
  len = length(trim(outbar));
run;

data _null_;
  set safe;
  file OUTGOOD;
  put @1 foo  @50 outbar $VARYING. len;
run;
 /*******/

