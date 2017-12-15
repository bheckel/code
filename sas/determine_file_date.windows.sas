 /* Windows-specific */
 
%let fname = junk;

filename p PIPE "dir .\&fname";

data diroutput;
  infile p;
  input cmdoutput $80.;
run;

data tmp;
  set diroutput;
  if index(cmdoutput, "&fname");  /* weak search b/c can't use LIKE '%' */
  dateoffile = input(scan(cmdoutput, 1, ' '), DATE9.);
  if dateoffile > 0;  /* slight improvement to weak search */
  call symput('DATEOFFILE', scan(cmdoutput, 1, ' '));
run;
proc print data=_LAST_ width=minimum; run;  

data _null_;
  set tmp;
  if dateoffile < today() then
    put "!!! uhoh &fname is old";
  else
    put "!!! ok &fname datestamp is &DATEOFFILE";
run;
