
options parmcards=extfile;
filename extfile 'parmfile';

proc explode;
	title 'holiday wishes courtesy of proc explode.  SAS rules!';
  parmcards;
 MERRY
 CHRISTMAS SHIRLEY AND SHAWN
  FROM BOB!
	;
run;

