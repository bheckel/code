/* A LINK question was in the Tekmetrics exam */

 /* SUGI 179-2008: Link statements are used to separate code from the normal
  * flow of the DATA Step in order that the code can be executed from any
  * location in the Step. This prevents the need to place the same code in
  * multiple locations in the Step, which greatly reduces the labor to modify
  * the Step when the code must be changed.
  *
  * A RETURN statement after a LINK statement returns execution to the
  * statement that follows LINK. A RETURN statement after a GO TO statement
  * returns execution to the beginning of the DATA step (unless a LINK
  * statement precedes GO TO, in which case execution continues with the first
  * statement after LINK).
  *
  * Links are very useful, but only if the same processing is applicable to
  * multiple fields.
  */

data sales; 
  input sale_no $ region $ commtype $ amount; 
  cards; 
111 WEST  1 3560.00 
222 NORTH 2 4000.00 
333 EAST  2 5200.00 
123 NORTH 1 1400.00 
223 WEST  2 6500.00 
344 SOUTH 1  500.00 
339 WEST  1 6899.00 
 ;
run; 
proc print; run;

data d; 
  set sales; 
  if region='WEST' then link west; 
  return; 

west: 
  if commtype ='1' then total=.5*amount; 
  else if commtype ='2' then total=.2*amount; 
  link accum; 

  output; 
  return; 

accum: 
  totals+total; 
return; 
run;  
proc print; run;


  /* The above example isn't useful outside an obfuscation contest */
data e;
  set sales;
  if region ne 'WEST' then delete; 

  if commtype ='1' then total=.5*amount; 
  else if commtype ='2' then total=.2*amount; 

  totals+total; 
run;
proc print; run;



 /* From SAS v8 Help file:///C:/Bookshelf_SAS/lgref/z0201972.htm */
data hydro;
  input type $ depth station $;
  /* link to label CALCU: */
  if type eq 'aluv' then link CALCU; 
  date=today();
  return;  /* return to top of step */

  put '!!!the dead zone';

  CALCU: if station='site_1' then elevatn=6650-depth;
  else if station='site_2' then elevatn=5500-depth;
  return;  /* return to date=today(); */
  datalines;
aluv 523 site_1
uppa 234 site_2
aluv 666 site_2
  ;
run;
proc print; run;
