 /*------------------------------------------------------------------*
  * Summary:   ytdsumout.sas   REQUIRES DATE CHANGES BELOW...
  *             
  *            Search & replace for ytdsumouti9827, etc.
  *
  *    Creates proc tabulate for eng & inst -- used for Thom G. to tie
  *   
  * Generated:  18Jun98 (Bob Heckel)  Revised: 24Jul98 (Bob Heckel)
  *------------------------------------------------------------------*/

options linesize=256 pagesize=32767 source notes source2 
        mprint errors=3 nocenter;

libname central '/test/ServOpsFinance/';

proc format;
  picture fmt low-<0='00009.90%' (prefix='-') other='00009.90%';
run;

/* Use Final criteria on central.costx
 * FTS Dt < Curr wk e.g. 9825 minus one or < Reporting wk e.g. 9823 
 * plus one.
 * Same as custfin.sas criteria                                    */
data work.temp1;
  set central.costx;
  where ftsdate ^= . and 
        ftsdate > 9751 and 
        ftsdate < 9828 and
        d_date ^= . and 
        ord_stat ^= 'CAN' and 
        prodline ^= 'D' and
	   distcode ^= 'OM68' and
	   job_id ^= 'H1X172'; /* ITW removed in Feb98 */
run;

 
/*Create YTD Inst Project Cost Summary Table"*/
proc printto file='~/Opfi/ytdsumout9827.txt' NEW;
run;

proc tabulate data=work.temp1;
  class nprdline class source_i;
  var i_cost dolrtrgi ibwdol;
  table nprdline*class*source_i all, i_cost dolrtrgi ibwdol /rts=14;
  label i_cost='Inst Act Cost'
        dolrtrgi='Inst Tgt Cost'
        nprdline='Prod'
        ibwdol='Inst B/(W) Dol'
        class = 'Class'
        source_i = 'I Src';
  title 'YTD Inst Project Cost Summary';
run;

proc printto;
run;


/* Create & append YTD Eng Project Cost Summary Table"*/
proc printto file='~/Opfi/ytdsumout9827.txt';
run;

proc tabulate data=work.temp1;
  class nprdline class source_e;
  var e_cost dolrtrge ebwdol;
  table nprdline*class*source_e all, e_cost dolrtrge ebwdol /rts=14;
  label e_cost='Eng Act Cost'
       dolrtrge='Eng Tgt Cost'
       nprdline='Prod'
       ebwdol='Eng B/(W) Dol'
       class = 'Class'
       source_e = 'E Src';
  title 'YTD Eng Project Cost Summary';
run;

proc printto;
run;
