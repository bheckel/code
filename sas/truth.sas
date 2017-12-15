
 /* SAS conception of Truth is anything other than False, False is 0 or . */

data _NULL_;
  file PRINT;
  ***foo = 42;
  /* same */
  foo = -2;
  if foo then
    put foo=;  /* TRUE */
  else 
    put "should NOT see this";

  foo = 0;
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */

  /* same */
  foo = .;
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */

  /* same */
  foo = '' ;
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */

  /* same */
  foo = ' ' ;
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */

  /* same */
  foo = '  ' ;
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */

  /* same */
  foo = .a;  /* SAS Special Missing Value .a thru .z */
  if foo then
    put "should NOT see this";
  else 
    put foo=;  /* FALSE */
run;
