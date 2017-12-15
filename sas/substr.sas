options nosource;
 /*---------------------------------------------------------------------
  *     Name: substr.sas
  *
  *  Summary: Demo of substr function.  See also index() or %index() if 
  *           need to determine if ALL chars are in a string.
  *
  *           1, not 0 based counting!!!
  *
  *  Created: Wed 23 Oct 2002 10:07:18 (Bob Heckel)
  * Modified: Tue 25 Nov 2008 14:08:42 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

data _null_;
  x='8ZM1234';
  if substr(x, 2, 1) eq 'Z' then
    put '!!!ok';
  else
    put '!!!not there';
run;



data _NULL_;
  length phonelong $12;

  /* Demo 1: */
  phonelong='800-555-1234';

  /* 1, not 0, based counting! */
  areacode=substr(phonelong, 1, 3);
  put areacode=;

  /* Position 5 to end of string. */
  other=substr(phonelong, 5);
  put other=;

  noseparators = compress(phonelong, '()-+.,/');
  put noseparators=;

  /* Demo 2: */
  phonenum='9195410458';
  put phonenum=;
  /* Assignable function as an lvalue!  A.K.A. a substr pseudo-variable when
   * used on the left side. 
   */
  substr(phonenum, 1, 3) = substr(noseparators, 1, 3);
  put phonenum=;
  substr(phonenum, 4, 1) = '-';
  put phonenum=;
  substr(phonenum, 5, 3) = substr(noseparators, 4, 3);
  put phonenum=;
  substr(phonenum, 8, 1) = '-';
  put phonenum=;

  /* Get the last char in a string substr(phonenum, -1, 1) won't work */
  lastch = substr(reverse(phonenum), 1, 1);
  put lastch=;

  /* Want to start 4 chars from the end of phonelong.  Can't use negative
   * subscript (as in Perl) to pull this off. 
   */
  fromend = length(phonelong) - 3;
  theend = substr(phonelong, fromend, 4);
  /* Print 1234 */
  put theend=;
  /* Print 4321 (easier to get end of string if you don't care about the
   * order) 
  */
  theend2 = substr(reverse(trim(phonelong)),1,4);
  put theend2=;
run;


data _null_;
  vallab = 'Not Reported (0)   ';
  if substr(reverse(left(trim(vallab))),2,1) in ('0','1','9') then
    put '!!!found desired digit';
run;
