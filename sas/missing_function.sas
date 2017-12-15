options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: missing_function.sas
  *
  *  Summary: Reports on missing char *or* num data.
  *
  *  Created: Thu 17 Jun 2004 16:03:31 (Bob Heckel)
  * Modified: Thu 15 Dec 2005 12:25:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data tmp;
  input @1 char1 $CHAR3.  @5 num1 3. @9 num2 3.;
  file PRINT;

  if missing(char1) then
    put 'Variable 1 is Missing.';
  else if missing(num1) then
    put 'Variable 2 is Missing.';
  else if missing(num2) then
    put 'Variable 3 is Missing.';
  datalines;
foo 127
bar 988 195
    988 195
  ;
run;



data missing;
  input char $ x y;
  if missing(char) then n_char + 1;
  if missing(x)  then n_x + 1;
  if missing(y)  then n_y + 1;
  datalines;
cody 5 6
. . .
whatley .a ._
last 10 20
  ;
run;
proc print data=missing noobs;
  title "listing of missing";
run;
