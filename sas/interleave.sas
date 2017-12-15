options nosource;
 /*---------------------------------------------------------------------------
  *     Name: interleave.sas
  *
  *  Summary: Demo of interleaving two datasets.  Ideally, sorting 2 small ds
  *           is better than one big one so interleaving is for efficiency and
  *           so that further processing by SAS is possible.
  *
  *           Many languages use the word 'interleave' to mean 'merge'.  
  *
  *           In SAS, the obs from interleaved ds are not combined, just
  *           copied from the original datasets in the order of the values of
  *           the BY variables.  
  *           I.e. Num obs ds A + num obs ds B = num obs ds C.
  *
  *  Adapted: Thu 06 Mar 2003 13:31:25 (Bob Heckel --
  *                          file:///C:/bookshelf_sas/lrcon/z1107839.htm)
  * Modified: Fri 11 Oct 2013 14:06:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data tmp1;
  input name $1-10  @30 numb 3.;
  datalines;
mario                        679
ron                          123
from1                        345
  ;
run;
 /* Mandatory. */
proc sort data=tmp1; by numb; run;
proc print NOobs; run;

data tmp2;
  input name $1-10  @30 numb 3.;
  datalines;
larry                        345
richard                      345
foo                          345
richard                      678
  ;
run;
 /* Mandatory. */
proc sort data=tmp2; by numb; run;
proc print NOobs; run;

title 'interleaved and contributing dataset noted';
data interleaved; 
  /*               ----->      */
  set tmp1 tmp2 INDSNAME=indsname;  /* V9 */
  by numb;  /* w/o this we would be concatenating datasets */
  put _all_;
  fname=indsname;
run;
proc print; run;

title "Compare concatenated (stacked) - no difference except for sorting in the previous step that isn't here";
data interleaved; 
  set tmp1 tmp2;
  put _all_;
run;
proc print; run;
