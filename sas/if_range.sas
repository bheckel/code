options NOsource;
 /*---------------------------------------------------------------------
  *     Name: if_range.sas
  *
  *  Summary: Demo of using IF to check a range with gaps.  
  *           WHERE BETWEEN won't work in a data step.
  *
  *  Created: Thu 13 Jun 2002 13:12:04 (Bob Heckel)
  * Modified: Wed 01 Oct 2003 16:35:23 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords nocenter source
        ;

data tmp;
  input num;
  cards;
27
30
34
140
999999
 ;
run;

data _NULL_;                   
  set tmp;
  /* Range with gaps 1-28, 33-45, 140 */
  if (num ge 1 and num le 28) or (num ge 33 and num le 45) or num eq 140 then
    do;
      put '!!! one' num=;
    end;
  if (num > 99999 and num < 999999) then 
    delete;
run;
