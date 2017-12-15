 /* Template for adhoc LMITHELP using MVDS queries.  Good for viewing single
  * records. 
  */
options NOcenter;

%include 'BQH0.PGM.LIB(TABDELIM)';

***libname MVDS 'BHB6.NAT2003.LIB';
libname MVDS 'DWJ2.MOR2003.MVDS.LIBRARY.NEW';

data work.tmp;
  /* Use bytepos(1) */
  set MVDS.IDNEW (keep= fileno);

  ***if mrace eq '8' and nowdead eq '77';
  if fileno lt '010000';
run;


data work.tmp;
  set work.tmp;
  ***label mrace = 'Race of Mother';
  ***label nowdead = 'Children Now Dead';
run;

proc print LABEL; run;

***%Tabdelim(work.tmp, 'BQH0.JUNK');
