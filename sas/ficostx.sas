
 /*------------------------------------------------------------------*
  *   Program Name:  ficostx.sas
  *
  *        Summary:  Output a proc tabulate to determine YTD spending.
  *                  Final jobs only.
  *                  Search and replace near  DATE 
  *                  Doesn't require as much manipulation as 
  *                  cancostx.sas  b/c using costx (which doesn't 
  *                  capture CAN).
  *                  Make changes to    DATE
  *
  *      Generated:  25Aug98 (Bob Heckel)
  *------------------------------------------------------------------*/

option linesize=95 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nonumber;

title; footnote;

libname arch '/extdisc/ARCHIVE/';


/* Left join with wk9751 */
proc sql;
 create table work.fincotmp as
  select a.job_id,
         a.ord_stat,
         a.rgncode,
         a.distcode,
	    a.prodline,
	    a.ftsdate,
         a.iacthrs,
         a.i_cost,
         /***b.job_id as jcnum,***/
         b.i_cost as i_cost97,
         b.emphrsi as emhrsi97,
         b.ctrhrsi as cohrsi97,
         b.vendhrsi as vehrsi97
  from arch.wk9832 a   /* DATE */
    left join
      arch.wk9751nd b
        on a.job_id = b.job_id;
quit;

/* Calc 97 iacthr97, act dollars ok as is */
data work.fincotmp;
  set work.fincotmp;
  /* Create a list of all numeric variables */
  array nums _numeric_;
  /* Process list, replace blanks with zeros */
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthr97 = emhrsi97 + cohrsi97 + vehrsi97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.fincotmp;
  set work.fincotmp;
  /* Create a list of all numeric variables */
  array nums _numeric_;
  /* Process list, replace blanks with zeros */
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthrsd = iacthrs - iacthr97;
  i_costd = i_cost - i_cost97;
run;

proc printto file='~/Spend/1998AugSpndFi.txt' NEW;   /* DATE */
run;

proc tabulate data=work.fincotmp;
    class rgncode;
    var iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
    table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
          i_costd /rts=12;
    label iacthrs = 'Inst Act Hrs'
          iacthr97 = '1997 Inst Act Hrs'
          iacthrsd = 'YTD Inst Act Hrs'
          i_cost = 'Inst Act Cost'
          i_cost97 = '1997 Inst Act Cost'
          i_costd = 'YTD Inst Act Cost';
    title 'Aug98 YTD Final Project Cost Spending';   /* DATE */
    /* See criteria.sas */
    where rgncode in ('C201','C202','C203','C204','C206','C208',
                      'C209','C210','C211','C212','C213') and
          job_id not like '$%' and
		prodline ^= 'D' and
		distcode ^= 'OM68' and
		job_id ^= 'H1X712' and
		ftsdate > 9751 and
          ftsdate < 9833; /* Preclose wk minus 1   DATE  */
run;

proc printto;
run;


/* Create OM68 and append to file */
data work.tmp1;
  set work.fincotmp;
      where distcode = 'OM68';
run;
 
proc printto file='~/Spend/1998AugSpndFi.txt';   /* DATE */
run;

proc tabulate data=work.tmp1;
    class rgncode;
    var i_cost iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
    table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
          i_costd /rts=12;
    label iacthrs = 'Inst Act Hrs'
          iacthr97 = '1997 Inst Act Hrs'
          iacthrsd = 'YTD Inst Act Hrs'
          i_cost = 'Inst Act Cost'
          i_cost97 = '1997 Inst Act Cost'
          i_costd = 'YTD Inst Act Cost';
    title 'Aug98 YTD Final Project Cost Spending OM68';   /* DATE */
    where rgncode in ('C201','C202','C203','C204','C206','C208',
                      'C209','C210','C211','C212','C213') and
          job_id not like '$%' and
		prodline ^= 'D' and
		job_id ^= 'H1X172' and
		ftsdate > 9751 and
          ftsdate < 9833; /* Preclose wk minus 1    DATE  */
run;

proc printto;
run;

/* TODO include Eng */
