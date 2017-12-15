 /* See also inplace_edit.sas */

filename MYXML "&DPPATH\CODE\_WSIP21.xml";
data _null_;
  infile MYXML TRUNCOVER;
  input @1 test $CHAR80.;
  if test eq: '<NewDataSet />' then do;
    put 'WARNING: Query returned no results, empty XML file exists.';
    file MYXML;
    put '<NewDataSet><Table><Name></Name><Ts></Ts><Value></Value></Table></NewDataSet>';
  end;
run;



endsas;

filename IN 'junk';
filename OUT 'junk2';

data tmp;
  infile IN truncover;
/***  input @1 block $CHAR80.;***/
  /* We *want* the potential leading spaces */
  input @1 block $80.;
run;


data _NULL_;
  set tmp;
  file OUT;
  put @1 block $80.;
run;



endsas;
filename in "in.txt";
data _null_;
   file in;
   input; 
   put _infile_;
   datalines4;
print this to file wiping out any existing text
;;;;
run;
